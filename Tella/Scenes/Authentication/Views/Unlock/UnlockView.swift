//
//  UnlockView.swift
//  Tella
//
//  Created by Gustavo on 16/08/2023.
//  Copyright © 2023 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import Combine

enum LockFlow {
    case new
    case update
}

struct UnlockView: View {
    
    @ObservedObject var viewModel: LockViewModel
    
    var type : PasswordTypeEnum
    var body: some View {
        ContainerView {
            VStack(alignment: .center, spacing: 0) {
                Spacer(minLength: 30)

                topView
                
                if type == .tellaPassword {
                    passwordView
                } else {
                    pinView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if viewModel.isLoading {
                CircularActivityIndicatory()
            }
            
        }
        .onAppear {
            viewModel.initUnlockData()
        }
        .onReceive(viewModel.mainAppModel.settings.$deleteAfterFail) { value  in
            viewModel.resetMaxAttempts()
        }
        .onReceive(viewModel.$presentingLockChoice) { presentingLockChoice in
            if presentingLockChoice {
                showLockChoiceView()
            }
        }.navigationBarHidden(true)
    }
    var passwordView: some View {
        Group {
            Spacer()
                .frame(height: .doubleLarge)
            
            PasswordTextFieldView(fieldContent: $viewModel.loginPassword,
                                  isValid: $viewModel.isValidPassword,
                                  shouldShowError: $viewModel.shouldShowUnlockError) {
                UIApplication.shared.endEditing()
            }
            
            Spacer()
            
            unlockPasswordButton
        }
    }
    
    var pinView: some View {
        Group {
            
            Spacer()
                .frame(height: .doubleLarge)
            
            PasswordTextFieldView(fieldContent: $viewModel.loginPassword,
                                  isValid: .constant(true),
                                  shouldShowError: $viewModel.shouldShowUnlockError,
                                  disabled: true)
            
            Spacer(minLength: 20)
            
            PinView(fieldContent: $viewModel.loginPassword,
                    keyboardNumbers: viewModel.unlockKeyboardNumbers) {
                viewModel.login()
            }
            
            Spacer()
        }
    }
    var topView: some View {
        VStack {
            Image(.tellaLogo)
                .frame(width: 65, height: 72)
                .aspectRatio(contentMode: .fit)
            
            Spacer()
                .frame(height: .normal)
            
            CustomText(titleString, style: .heading1Style, alignment: .center)
                .padding(.horizontal, 67)
            
            if viewModel.shouldShowAttemptsWarning {
                Spacer()
                    .frame(height: .normal)
                
                CustomText(viewModel.warningText(), style: .body1Style, alignment: .center)
                    .padding(.horizontal, 67)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var unlockPasswordButton: some View {
        if $viewModel.isValidPassword.wrappedValue {
            NextBottomView(
                title: LocalizableLock.unlockPasswordAction.localized,
                isValid: $viewModel.isValidPassword
            ) {
                viewModel.login()
            }
        }
        
    }
    
    var titleString: String {
        let unlockErrorString: String
        let unlockSubheadString: String
        
        switch type {
        case .tellaPin:
            unlockErrorString = viewModel.shouldShowUnlockError ? LocalizableLock.unlockUpdatePinErrorIncorrectPIN.localized : ""
            unlockSubheadString = viewModel.lockFlow == .new ? LocalizableLock.unlockPinSubhead.localized : LocalizableLock.unlockUpdatePinSubhead.localized
        default:
            unlockErrorString = viewModel.shouldShowUnlockError ? LocalizableLock.unlockUpdatePasswordErrorIncorrectPassword.localized : ""
            unlockSubheadString = viewModel.lockFlow == .new ? LocalizableLock.unlockPasswordSubhead.localized : LocalizableLock.unlockUpdatePasswordSubhead.localized
        }
        
        return unlockErrorString.isEmpty ? unlockSubheadString : unlockErrorString
    }
    
    private func showLockChoiceView() {
        navigateTo(destination: LockChoiceView(lockViewModel: viewModel))
    }
}

struct UnlockView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockView(viewModel: LockViewModel.stub(), type: .tellaPassword)
    }
}
