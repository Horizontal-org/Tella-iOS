//
//  UnlockPasswordView.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine

enum UnlockType {
    case new
    case update
}

struct UnlockPasswordView: View {
    @EnvironmentObject private var appViewState: AppViewState
    
    @EnvironmentObject private var viewModel: LockViewModel
    @State private var presentingLockChoice : Bool = false
    @State private var isLoading : Bool = false
    @State private var cancellable: Set<AnyCancellable> = []
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ContainerView {
            VStack(alignment: .center) {
                
                Spacer()
                
                Image("tella.logo")
                    .frame(width: 65, height: 72)
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                    .frame(height: 50)
                
                Text(titleString)
                    .font(.custom(Styles.Fonts.regularFontName, size: 18))
                    .foregroundColor(.white)
                    .lineSpacing(7)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 0, leading: 67, bottom: 0, trailing: 67))
                Spacer()
                    .frame(height: 50)
                
                if(viewModel.shouldShowAttemptsWarning) {
                    Text(viewModel.warningText())
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                        .lineSpacing(7)
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 0, leading: 67, bottom: 0, trailing: 67))
                }
                Spacer()
                    .frame(height: 73)
                
                PasswordTextFieldView(fieldContent: $viewModel.loginPassword,
                                      isValid: .constant(true),
                                      shouldShowError: $viewModel.shouldShowUnlockError) {
                    viewModel.login()
                    if !viewModel.shouldShowUnlockError {
                        if viewModel.unlockType == .new {
                            isLoading = true
                            initRoot()
                        } else {
                            presentingLockChoice = true
                        }
                    } else {
                        viewModel.unlockAttempts = viewModel.unlockAttempts + 1
                        
                        if(viewModel.unlockAttempts == viewModel.maxAttempts) {
                            viewModel.removeFilesAndConnections()
                        }
                    }
                }
                Spacer()
            }
        }
        .overlay(lockChoiceView)
        
        .onAppear {
            viewModel.initUnlockData()
        }
    }
    
    var titleString : String {
        if viewModel.shouldShowUnlockError {
            return  LocalizableLock.unlockUpdatePasswordErrorIncorrectPassword.localized
        } else {
            return viewModel.unlockType == .new ? LocalizableLock.unlockPasswordSubhead.localized : LocalizableLock.unlockUpdatePasswordSubhead.localized
        }
        
    }
    
    var lockChoiceView : some View {
        presentingLockChoice ? LockChoiceView( isPresented: $presentingLockChoice) : nil
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

struct UnlockPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockPasswordView()
    }
}
