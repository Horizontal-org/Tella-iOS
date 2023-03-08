//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SuccessLoginView: View {
    
//    @Binding var isPresented : Bool
    @EnvironmentObject var mainAppModel : MainAppModel
    @EnvironmentObject var serversViewModel : ServersViewModel
    @EnvironmentObject private var appViewState: AppViewState
    @State var showNextView : Bool = false
    
    var body: some View {
        
        NavigationContainerView {
            
            VStack {
                
                Spacer()
                
                topview
                
                Spacer()
                    .frame(height: 48)
                
                TellaButtonView<AnyView> (title: "GO TO REPORTS",
                                          nextButtonAction: .action,
                                          buttonType: .yellow,
                                          isValid: .constant(true)) {
                    
                    //                    showNextView = true
                    
                    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    //                        isPresented = false
                    //                                   mainAppModel.selectedTab = .home
                    //
                    //                    }
                    
                }
                
                Spacer()
                    .frame(height: 12)
                
                TellaButtonView (title: "Advanced settings",
                                 nextButtonAction: .destination,
                                 destination: AdvancedServerSettingsView(),
                                 isValid: .constant(true))
                Spacer()
                
            } .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 26))
            nextViewLink
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
    
    private var nextViewLink: some View {
        
        ReportsView(mainAppModel: mainAppModel, serverLinkIsActive: $serversViewModel.rootLinkIsActive)
            .addNavigationLink(isActive: $showNextView)
    }
    
}

struct SuccessLoginView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessLoginView()
    }
}