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

enum UnlockType {
    case new
    case update
}

struct UnlockView: View {

    @EnvironmentObject private var viewModel: LockViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

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
            
            if  viewModel.isLoading {
                CircularActivityIndicatory()
            }
            
        }
        .onAppear {
            viewModel.initUnlockData()
        }
        .onReceive(viewModel.appModel.settings.$deleteAfterFail) { value  in
            viewModel.resetMaxAttempts()
        }
        .onReceive(viewModel.$presentingLockChoice) { presentingLockChoice in
            if presentingLockChoice {
                showLockChoiceView()
            }
        }.navigationBarHidden(true)
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
            viewModel.login()
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
                viewModel.login()
            }
        }
    }
    private func showLockChoiceView() {
        navigateTo(destination: LockChoiceView().environmentObject(viewModel))
    }
}

struct UnlockView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockView(type: .tellaPassword)
    }
}
