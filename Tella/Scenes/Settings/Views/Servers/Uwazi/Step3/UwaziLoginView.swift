//
//  UwaziLoginView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/24/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import SwiftUI

struct UwaziLoginView: View {
    @EnvironmentObject var serverViewModel : UwaziServerViewModel
    @EnvironmentObject var serversViewModel : ServersViewModel

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var mainAppModel : MainAppModel

    @State var presentingSuccessLoginView : Bool = false

    fileprivate func usernameTextFieldView() -> some View {
        return TextfieldView(fieldContent: $serverViewModel.username,
                             isValid: $serverViewModel.validUsername,
                             shouldShowError: $serverViewModel.shouldShowLoginError,
                             fieldType: .username,
                             placeholder : LocalizableSettings.UwaziUsername.localized)
        .autocapitalization(.none)
        .frame(height: 30)
    }

    fileprivate func passwordTextFieldView() -> some View {
        return TextfieldView(fieldContent: $serverViewModel.password,
                             isValid: $serverViewModel.validPassword,
                             shouldShowError: $serverViewModel.shouldShowLoginError,
                             errorMessage: serverViewModel.loginErrorMessage,
                             fieldType: .password,
                             placeholder : LocalizableSettings.UwaziPassword.localized)
        .autocapitalization(.none)
        .frame(height: 57)
    }

    fileprivate func loginButtonView() -> TellaButtonView<AnyView> {
        return TellaButtonView<AnyView>(title: LocalizableSettings.UwaziLogin.localized,
                                        nextButtonAction: .action,
                                        isValid: $serverViewModel.validCredentials) {
            UIApplication.shared.endEditing()
            self.serverViewModel.login()
        }
    }

    var body: some View {

        ContainerView {
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

                    BottomLockView<AnyView>(isValid: $serverViewModel.validPassword,
                                            nextButtonAction: .action,
                                            shouldHideNext: true)
                }
                if serverViewModel.isLoading {
                    CircularActivityIndicatory()
                }
            }
        }
        .navigationBarHidden(true)
        .onReceive(serverViewModel.$showNextLanguageSelectionView, perform: { value in
            if value {
                let languageView = UwaziLanguageSelectionView(isPresented: .constant(true))
                    //.environmentObject(SettingsViewModel(appModel: MainAppModel()))
                    .environmentObject(serversViewModel)
                    .environmentObject(serverViewModel)
                navigateTo(destination: languageView)
            }
        })
        .onReceive(serverViewModel.$showNext2FAView, perform: { value in
            if value {
                let twoStepVerification =  UwaziTwoStepVerification()
                                        .environmentObject(serversViewModel)
                                        .environmentObject(serverViewModel)
                if !serverViewModel.shouldShowLoginError {
                    navigateTo(destination: twoStepVerification)
                }
            }
        })
        .onAppear {
            if serverViewModel.currentServer != nil {
                serverViewModel.validCredentials = true
            } else {}
        }
    }
}

struct UwaziLoginView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziLoginView()
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel.stub()))
            .environmentObject(ServerViewModel(mainAppModel: MainAppModel.stub(), currentServer: nil))
    }
}
