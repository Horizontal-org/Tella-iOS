//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct TellaWebAddServerURLView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var nextButtonAction: NextButtonAction = .action
    @StateObject var serverViewModel : TellaWebServerViewModel

    init(mainAppModel:MainAppModel, server: TellaServer? = nil,
         serversSourceView: ServersSourceView) {
        _serverViewModel = StateObject(wrappedValue: TellaWebServerViewModel(mainAppModel: mainAppModel, currentServer: server, serversSourceView: serversSourceView))
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
                    
                    NavigationBottomView<AnyView>(shouldActivateNext: $serverViewModel.validURL,
                                            nextButtonAction: .action,
                                            nextAction: {
                        // serverViewModel.checkURL()
                        navigateTo(destination: serverLoginView)
                        
                    },
                                            backAction: {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                    
                    
                    
                } .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                
                if serverViewModel.isLoading {
                    CircularActivityIndicatory()
                }
            }
        }.navigationBarHidden(true)
    }
    
    private var serverLoginView: some View {
        TellaWebServerLoginView(serverViewModel: serverViewModel)
    }
}

struct AddServerURLView_Previews: PreviewProvider {
    static var previews: some View {
        TellaWebAddServerURLView(mainAppModel: MainAppModel.stub(), serversSourceView: .settings)
    }
}
