//
//  UnlockView.swift
//  Tella
//
//  Created by Gustavo on 16/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI
import Combine

enum UnlockType {
    case new
    case update
}

struct UnlockView: View {
    @State private var presentingLockChoice : Bool = false
    
    @EnvironmentObject private var appViewState: AppViewState
    
    @EnvironmentObject private var viewModel: LockViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var cancellable: Set<AnyCancellable> = []
    @State private var isLoading : Bool = false
    var type : PasswordTypeEnum
    var body: some View {
        ContainerView {
            VStack(alignment: .center) {
                Spacer(minLength: 30)
                
                Image("tella.logo")
                    .frame(width: 65, height: 72)
                    .aspectRatio(contentMode: .fit)
                
                Spacer(minLength: 23)
                
                TextView(content: titleString, size: 18)
                
                Spacer()
                
                if(viewModel.shouldShowAttemptsWarning) {
                    TextView(content: viewModel.warningText(), size: 14)
                    Spacer()
                }
                
    
                if(type == .tellaPassword) {
                    TellaPasswordView
                } else {
                    TellaPinView
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
    
    
    var titleString: String {
        let unlockErrorString: String
        let unlockSubheadString: String

        switch type {
        case .tellaPin:
            unlockErrorString = viewModel.shouldShowUnlockError ? LocalizableLock.unlockUpdatePinErrorIncorrectPIN.localized : ""
            unlockSubheadString = viewModel.unlockType == .new ? LocalizableLock.unlockPinSubhead.localized : LocalizableLock.unlockUpdatePinSubhead.localized
        default:
            unlockErrorString = viewModel.shouldShowUnlockError ? LocalizableLock.unlockUpdatePasswordErrorIncorrectPassword.localized : ""
            unlockSubheadString = viewModel.unlockType == .new ? LocalizableLock.unlockPasswordSubhead.localized : LocalizableLock.unlockUpdatePasswordSubhead.localized
        }

        return unlockErrorString.isEmpty ? unlockSubheadString : unlockErrorString
    }
    
    var TellaPasswordView : some View {
        PasswordTextFieldView(fieldContent: $viewModel.loginPassword,
                              isValid: .constant(true),
                              shouldShowError: $viewModel.shouldShowUnlockError) {
            loginActions()
        }
    }
    
    var TellaPinView : some View {
        Group {
            PasswordTextFieldView(fieldContent: $viewModel.loginPassword,
                                  isValid: .constant(true),
                                  shouldShowError: $viewModel.shouldShowUnlockError,
                                  disabled: true)
            
            Spacer(minLength: 20)
            
            PinView(fieldContent: $viewModel.loginPassword,
                    keyboardNumbers: viewModel.unlockKeyboardNumbers) {
                loginActions()
            }
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
        viewModel.resetUnlockAttempts()
        if viewModel.unlockType == .new {
             isLoading = true
            initFiles()
        } else {
            presentingLockChoice = true
        }
    }
    
    private func checkUnlockAttempts() {
        viewModel.increaseUnlockAttempts()
                                
        if(viewModel.unlockAttempts == viewModel.maxAttempts) {
            viewModel.removeFilesAndConnections()
            appViewState.resetApp()
        }
    }
    
    private func initFiles() {
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

struct UnlockView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockView(type: .tellaPassword)
    }
}
