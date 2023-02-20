//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddServerURLView: View {
    
    //    @EnvironmentObject var serversViewModel : ServersViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    //    var action : (() -> Void)?
    var nextButtonAction: NextButtonAction = .action
    
    
    @EnvironmentObject var serversViewModel : ServersViewModel
    @StateObject var serverViewModel : ServerViewModel
    @State var showNextLoginView : Bool = false

    init(appModel:MainAppModel, server: Server? = nil) {
        _serverViewModel = StateObject(wrappedValue: ServerViewModel(mainAppModel: appModel, currentServer: server))
    }
    
    var body: some View {
        
        ContainerView {
            
            ZStack {
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 80)
                    
                    Image("settings.server")
                    
                    
                    Spacer()
                        .frame(height: 24)
                    
                    Text("Enter the project URL")
                        .font(.custom(Styles.Fonts.regularFontName, size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    TextfieldView(fieldContent: $serverViewModel.projectURL,
                                  isValid: $serverViewModel.validURL,
                                  shouldShowError: $serverViewModel.shouldShowURLError,
                                  errorMessage: serverViewModel.urlErrorMessage,
                                  fieldType: .url)
                    Spacer()
                    
                    BottomLockView<AnyView>(isValid: $serverViewModel.validURL,
                                            nextButtonAction: .action,
                                            nextAction: {
//                        serverViewModel.checkURL()
                        self.showNextLoginView = true
                    },
                                            backAction: {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                    
                    nextViewLink
                    
                } .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                
                if serverViewModel.isLoading {
                    CircularActivityIndicatory()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            
#if DEBUG
            serverViewModel.projectURL = "https://api.beta.web.tella-app.org/p/organizacion-1"
#endif
        }
    }
    
    private var nextViewLink: some View {
        
        ServerLoginView()
            .environmentObject(serverViewModel)
            .environmentObject(serversViewModel)
            .addNavigationLink(isActive: $showNextLoginView)
    }
    
}

struct AddServerURLView_Previews: PreviewProvider {
    static var previews: some View {
        AddServerURLView(appModel: MainAppModel())
    }
}
