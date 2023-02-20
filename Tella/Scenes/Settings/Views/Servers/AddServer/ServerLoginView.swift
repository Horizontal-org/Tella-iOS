//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ServerLoginView: View {
    
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
                        
                        TopServerView(title: "Log in to access the project")
                        
                        Spacer()
                            .frame(height: 40)
                        
                        TextfieldView(fieldContent: $serverViewModel.username,
                                      isValid: $serverViewModel.validUsername,
                                      shouldShowError: $serverViewModel.shouldShowLoginError,
                                      //                                      errorMessage: nil,
                                      fieldType: .username,
                                      placeholder : "Username")
                        .frame(height: 30)
                        
                        Spacer()
                            .frame(height: 27)
                        
                        TextfieldView(fieldContent: $serverViewModel.password,
                                      isValid: $serverViewModel.validPassword,
                                      shouldShowError: $serverViewModel.shouldShowLoginError,
                                      errorMessage: serverViewModel.loginErrorMessage,
                                      fieldType: .password,
                                      placeholder : "Password")
                        .frame(height: 57)
                        
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
        
        if !serverViewModel.shouldShowLoginError {
            SuccessLoginView()
                .environmentObject(serverViewModel)
                .environmentObject(serversViewModel)
                .addNavigationLink(isActive: $serverViewModel.showNextSuccessLoginView)
        }
    }
}

struct ServerLoginView_Previews: PreviewProvider {
    static var previews: some View {
        ServerLoginView()
    }
}
