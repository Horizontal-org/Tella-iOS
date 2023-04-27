//
//  UwaziLoginView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/24/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import SwiftUI

struct UwaziLoginView: View {
    @EnvironmentObject var serverViewModel : ServerViewModel
    @EnvironmentObject var serversViewModel : ServersViewModel

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var mainAppModel : MainAppModel

    @State var presentingSuccessLoginView : Bool = false

    var body: some View {

        ContainerView {

            ZStack {

                VStack(spacing: 0) {

                    VStack(spacing: 0) {

                        Spacer()

                        TopServerView(title: LocalizableSettings.UwaziLoginAccess.localized)

                        Spacer()
                            .frame(height: 40)

                        TextfieldView(fieldContent: $serverViewModel.username,
                                      isValid: $serverViewModel.validUsername,
                                      shouldShowError: $serverViewModel.shouldShowLoginError,
                                      //                                      errorMessage: nil,
                                      fieldType: .username,
                                      placeholder : LocalizableSettings.UwaziUsername.localized)
                        .frame(height: 30)

                        Spacer()
                            .frame(height: 27)

                        TextfieldView(fieldContent: $serverViewModel.password,
                                      isValid: $serverViewModel.validPassword,
                                      shouldShowError: $serverViewModel.shouldShowLoginError,
                                      errorMessage: serverViewModel.loginErrorMessage,
                                      fieldType: .password,
                                      placeholder : LocalizableSettings.UwaziPassword.localized)
                        .frame(height: 57)

                        Spacer()
                            .frame(height: 32)

                        TellaButtonView<AnyView>(title: LocalizableSettings.UwaziLogin.localized,
                                                 nextButtonAction: .action,
                                                 isValid: $serverViewModel.validCredentials) {
                            UIApplication.shared.endEditing()
                            serverViewModel.shouldShowLoginError = false
                            serverViewModel.showNextSuccessLoginView = true
                            //serverViewModel.login()
                        }

                        Spacer()


                    }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                    BottomLockView<AnyView>(isValid: $serverViewModel.validPassword,
                                            nextButtonAction: .action,
                                            shouldHideNext: true)
                }

                nextViewLink

                if serverViewModel.isLoading {
                    CircularActivityIndicatory()
                }
            }

        }
        .navigationBarHidden(true)
        .onAppear {

            #if DEBUG
                        serverViewModel.username = "admin@wearehorizontal.org"
                        serverViewModel.password = "nadanada"
            #endif
        }
    }

    @ViewBuilder
    private var nextViewLink: some View {
            UwaziTwoStepVerification()
            .environmentObject(serversViewModel)
            .environmentObject(serverViewModel)
                //.addNavigationLink(isActive: $serverViewModel.showNextSuccessLoginView)
        if !serverViewModel.shouldShowLoginError {
//            SuccessLoginView()
//                .environmentObject(serverViewModel)
//                .environmentObject(serversViewModel)
//                .addNavigationLink(isActive: $serverViewModel.showNextSuccessLoginView)
        }
    }

}

struct UwaziLoginView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziLoginView()
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel()))
            .environmentObject(ServerViewModel(mainAppModel: MainAppModel(), currentServer: nil))
    }
}
