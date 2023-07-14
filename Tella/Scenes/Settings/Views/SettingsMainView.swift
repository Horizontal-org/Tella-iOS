//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsMainView: View {
    
    @EnvironmentObject var appModel : MainAppModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var settingsViewModel : SettingsViewModel
    @StateObject var serversViewModel : ServersViewModel
    
    init(appModel:MainAppModel) {
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(appModel: appModel))
        _serversViewModel = StateObject(wrappedValue: ServersViewModel(mainAppModel: appModel))
    }
    
    var body: some View {
        
        ContainerView {
            
            VStack(spacing:0) {
                
                Spacer()
                    .frame(height: 8)
                
                SettingsCardView(cardViewArray: [generalView.eraseToAnyView(),
                                                 securityView.eraseToAnyView(),
                                                 serversView.eraseToAnyView(),
                                                 helpView.eraseToAnyView()])
                Spacer()
            }
        }
        
        .toolbar {
            LeadingTitleToolbar(title: LocalizableSettings.settAppBar.localized)
        }
        
        .onDisappear {
            appModel.publishUpdates()
        }
    }
    
    var generalView: some View {
        SettingsItemView(imageName: "settings.general",
                         title: LocalizableSettings.settGenAppBar.localized,
                         destination:
                            GeneralView().environmentObject(settingsViewModel))
    }
    
    

    var securityView: some View {
        SettingsItemView(imageName: "settings.lock",
                         title: LocalizableSettings.settSecAppBar.localized,
                         destination:securitySettingsView)
    }
    
    var serversView: some View {
        SettingsItemView(imageName: "settings.servers",
                         title: LocalizableSettings.settServersAppBar.localized,
                         destination:ServersListView()
            .environmentObject(serversViewModel))
    }
    
    var helpView: some View {
        SettingsItemView(imageName: "settings.help",
                         title: LocalizableSettings.settAbout.localized,
                         destination:AboutAndHelpView().environmentObject(settingsViewModel))
    }
    
    var securitySettingsView: some View {
        SecuritySettingsView()
            .environmentObject(settingsViewModel)
    }
}

struct SettingsMainView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMainView(appModel: MainAppModel.stub())
    }
}
