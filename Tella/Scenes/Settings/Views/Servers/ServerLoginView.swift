//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ServerLoginView: View {
    
    @EnvironmentObject var serversViewModel : ServersViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var mainAppModel : MainAppModel
    
    @State var presentingSuccessLoginView : Bool = false
    @State var showNextView : Bool = false
    
    var body: some View {
        
        ContainerView {
            VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    TopServerView(title: "Log in to access the project")
                    
                    
                    Spacer()
                        .frame(height: 40)
                    
                    TextfieldView(fieldContent: $serversViewModel.username,
                                  isValid: $serversViewModel.validUsername,
                                  shouldShowError: $serversViewModel.shouldShowLoginError,
                                  errorMessage: nil,
                                  fieldType: .username,
                                  title : "Username")
                    .frame(height: 30)
                    
                    Spacer()
                        .frame(height: 27)
                    
                    TextfieldView(fieldContent: $serversViewModel.password,
                                  isValid: $serversViewModel.validPassword,
                                  shouldShowError: $serversViewModel.shouldShowLoginError,
                                  errorMessage: serversViewModel.loginErrorMessage,
                                  fieldType: .password,
                                  title : "Password")
                    .frame(height: 57)
                    
                    Spacer()
                        .frame(height: 32)
                    
                    TellaButtonView<AnyView>(title: "LOG IN",
                                             nextButtonAction: .action) {
                        UIApplication.shared.endEditing()
                        
                        serversViewModel.login()
                        
                        presentingSuccessLoginView = !serversViewModel.shouldShowLoginError
//                        showNextView = !serversViewModel.shouldShowLoginError
                    }
                    
                    Spacer()
                    
                    
                }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                
                BottomLockView<AnyView>(isValid: $serversViewModel.validPassword,
                                        nextButtonAction: .action,
                                        shouldHideNext: true)
                
            }
//            nextViewLink
        }
        .fullScreenCover(isPresented: $presentingSuccessLoginView) {

        } content: {
            SuccessLoginView(isPresented: $presentingSuccessLoginView).environmentObject(serversViewModel)
        }
        
        .navigationBarHidden(true)
    }
    
    
    private var nextViewLink: some View {
        SuccessLoginView(isPresented: $presentingSuccessLoginView).environmentObject(serversViewModel)
            .addNavigationLink(isActive: $showNextView)
    }
    
}



//struct ServerLoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServerLoginView()
//    }
//}
