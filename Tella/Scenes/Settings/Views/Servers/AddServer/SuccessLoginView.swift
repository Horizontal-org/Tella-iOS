//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SuccessLoginView: View {
    @EnvironmentObject var mainAppModel : MainAppModel
    @EnvironmentObject var serversViewModel : ServersViewModel
    @EnvironmentObject var serverViewModel : TellaWebServerViewModel
    @EnvironmentObject private var appViewState: AppViewState
    @State var showNextView : Bool = false
    
    var navigateToAction: () -> Void
    var type: ServerConnectionType = .tella
    var body: some View {
        
        ContainerView {
            
            VStack {
                
                Spacer()
                
                topview
                
                Spacer()
                    .frame(height: 48)
                
                TellaButtonView<AnyView> (title: type.successConnectionButtonContent,
                                          nextButtonAction: .action,
                                          buttonType: .yellow,
                                          isValid: .constant(true)) {
                    navigateToAction()
                }
                
                Spacer()
                    .frame(height: 12)
                
                if type == .tella {
                    TellaButtonView (title: LocalizableSettings.advancedSettings.localized,
                                     nextButtonAction: .destination,
                                     destination: AdvancedServerSettingsView()
                        .environmentObject(serverViewModel),
                                     isValid: .constant(true))
                }
                Spacer()
                
            } .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 26))
        }
        .navigationBarHidden(true)
    }
    
    var topview: some View {
        
        VStack {
            Image("settings.checked-circle")
            
            Spacer()
                .frame(height: 16)
            
            Text("Connected to project")
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Spacer()
                .frame(height: 16)
            
            Text("You have successfully connected to the server and will be able to share your data.")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
}

struct SuccessLoginView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessLoginView(navigateToAction: {})
            .environmentObject(MainAppModel.stub())
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel.stub()))
    }
}
