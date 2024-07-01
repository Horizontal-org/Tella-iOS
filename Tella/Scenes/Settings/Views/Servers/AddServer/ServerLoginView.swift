//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ServerLoginView: View {
    
    @EnvironmentObject var serverViewModel : TellaWebServerViewModel
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
                        
                        TopServerView(title: "Log in to access the project")
                        
                        Spacer()
                            .frame(height: 40)
                        
                        TextfieldView(fieldContent: $serverViewModel.username,
                                      isValid: $serverViewModel.validUsername,
                                      shouldShowError: $serverViewModel.shouldShowLoginError,
                                      fieldType: .username,
                                      placeholder : "Username",
                                      shouldShowTitle: true)

                        Spacer()
                            .frame(height: 13)
                        
                        TextfieldView(fieldContent: $serverViewModel.password,
                                      isValid: $serverViewModel.validPassword,
                                      shouldShowError: $serverViewModel.shouldShowLoginError,
                                      errorMessage: serverViewModel.loginErrorMessage,
                                      fieldType: .password,
                                      placeholder : "Password",
                                      shouldShowTitle: true)

                        Spacer()
                            .frame(height: 32)

                        TellaButtonView<AnyView>(title: "LOG IN",
                                                 nextButtonAction: .action,
                                                 isValid: $serverViewModel.validCredentials) {
                            UIApplication.shared.endEditing()
                            serverViewModel.login()
                        }
                        
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
        .onReceive(serverViewModel.$showNextSuccessLoginView) { value in
            if value {
                navigateTo(destination: successLoginView)
            }
        }

    }
    
    private var successLoginView: some View {
        SuccessLoginView(navigateToAction: {
            navigateTo(destination: ReportsView(mainAppModel: mainAppModel))
        }).environmentObject(serverViewModel)
    }
    
}
