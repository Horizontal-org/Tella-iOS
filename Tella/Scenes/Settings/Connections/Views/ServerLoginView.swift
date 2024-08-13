//
//  ServerLoginView.swift
//  Tella
//
//  Created by RIMA on 1/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
struct ServerLoginView: View {
    
    @StateObject var viewModel: ServerViewModel
    @EnvironmentObject var serversViewModel : ServersViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var successLoginAction: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack(spacing: 32) {
                    Spacer()
                    TopServerView(title: LocalizableSettings.UwaziLoginAccess.localized)
                    usernameTextFieldView()
                    passwordTextFieldView()
                    loginButtonView()
                    Spacer()
                }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                
                BottomLockView<AnyView>(isValid: $viewModel.validPassword,
                                        nextButtonAction: .action,
                                        shouldHideNext: true)
            }
            
            handleState
        }
        .onReceive(viewModel.$loginState) { value in
            if value == .loaded(true) {
                successLoginAction?()
            }
        }

        .containerStyle()
        .navigationBarHidden(true)
    }
    
    fileprivate func usernameTextFieldView() -> some View {
        return TextfieldView(fieldContent: $viewModel.username,
                             isValid: $viewModel.validUsername,
                             shouldShowError: $viewModel.shouldShowLoginError,
                             fieldType: .text,
                             placeholder : LocalizableSettings.serverUsername.localized)
        .autocapitalization(.none)
        .frame(height: 30)
    }
    
    fileprivate func passwordTextFieldView() -> some View {
        return TextfieldView(fieldContent: $viewModel.password,
                             isValid: $viewModel.validPassword,
                             shouldShowError: $viewModel.shouldShowLoginError,
                             errorMessage: viewModel.loginErrorMessage,
                             fieldType: .password,
                             placeholder : LocalizableSettings.serverPassword.localized)
        .autocapitalization(.none)
        .frame(height: 57)
    }
    
    fileprivate func loginButtonView() -> TellaButtonView<AnyView> {
        return TellaButtonView<AnyView>(title: LocalizableSettings.UwaziLogin.localized,
                                        nextButtonAction: .action,
                                        isValid: $viewModel.validCredentials) {
            UIApplication.shared.endEditing()
            self.viewModel.login()
        }
    }
    
    @ViewBuilder
    private var handleState : some View {
        switch viewModel.loginState {
        case .loading:
            CircularActivityIndicatory()
        case .error(let message):
            if !message.isEmpty {
                VStack { // This VStack is used to display the Toast View Properly
                    Spacer()
                    ToastView(message: message)
                }
            }
        default:
            EmptyView()
        }
    }
}
