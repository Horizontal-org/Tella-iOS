//
//  UnlockPinView.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine

struct UnlockPinView: View {
    
    @State private var presentingLockChoice : Bool = false
    
    @EnvironmentObject private var appViewState: AppViewState
    
    @EnvironmentObject private var viewModel: LockViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var cancellable: Set<AnyCancellable> = []
    @State private var isLoading : Bool = false

    var body: some View {
        ContainerView {
            VStack(alignment: .center) {
                Spacer(minLength: 30)
                
                Image("tella.logo")
                    .frame(width: 65, height: 72)
                    .aspectRatio(contentMode: .fit)
                
                Spacer(minLength: 23)
                
                Text(titleString)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                    .foregroundColor(.white)
                    .lineSpacing(7)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 0, leading: 67, bottom: 0, trailing: 67))
                
                Spacer()
                
                if(viewModel.shouldShowAttemptsWarning) {
                    Text(viewModel.warningText())
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                        .lineSpacing(7)
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 0, leading: 67, bottom: 0, trailing: 67))
                    Spacer()
                }

               
                
                PasswordTextFieldView(fieldContent: $viewModel.loginPassword,
                                      isValid: .constant(true),
                                      shouldShowError: $viewModel.shouldShowUnlockError,
                                      disabled: true)
                
                Spacer(minLength: 20)
                
                PinView(fieldContent: $viewModel.loginPassword,
                        keyboardNumbers: UnlockKeyboardNumbers) {
                    loginActions()
                }
                
                Spacer()
            }
            
            if  isLoading {
                CircularActivityIndicatory()
            }
            
        }
        
        .overlay(lockChoiceView)
        .onAppear {
            viewModel.initUnlockData()
        }
    }
    
    var titleString : String {
        if viewModel.shouldShowUnlockError {
            return  LocalizableLock.unlockUpdatePinErrorIncorrectPIN.localized
        } else {
            return viewModel.unlockType == .new ? LocalizableLock.unlockPinSubhead.localized : LocalizableLock.unlockUpdatePinSubhead.localized
        }
    }
    
    var lockChoiceView : some View {
        presentingLockChoice ? LockChoiceView( isPresented: $presentingLockChoice) : nil
    }
    
    private func loginActions() {
        viewModel.login()
        if !viewModel.shouldShowUnlockError {
            successLogin()
        } else {
            checkUnlockAttempts()
        }
    }
    
    private func successLogin() {
        viewModel.unlockAttempts = 0
        if viewModel.unlockType == .new {
             isLoading = true
             initRoot()
        } else {
            presentingLockChoice = true
        }
    }
    
    private func checkUnlockAttempts() {
        viewModel.unlockAttempts = viewModel.unlockAttempts + 1
        UserDefaults.standard.set(viewModel.unlockAttempts, forKey: "com.tella.lock.attempts")
                                
        if(viewModel.unlockAttempts == viewModel.maxAttempts) {
            viewModel.removeFilesAndConnections()
        }
    }
    
    private func initRoot() {
        DispatchQueue.main.async {
            appViewState.homeViewModel.initFiles()
                .receive(on: DispatchQueue.main)
                .sink { recoverResult in
                    isLoading = false
                    appViewState.showMainView()
                }.store(in: &self.cancellable)
        }
    }
    
}

struct UnlockPinView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockPinView()
    }
}
