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
        
        .environmentObject(settingsViewModel)
        .environmentObject(serversViewModel)

    }
    
    var generalView: some View {
        SettingsItemView<AnyView>(imageName: "settings.general",
                                  title: "General",
                                  destination:
                                    GeneralView().environmentObject(settingsViewModel) .eraseToAnyView())
    }
    
    var securityView: some View {
        SettingsItemView<AnyView>(imageName: "settings.lock",
                                  title: "Security",
                                  destination:SecuritySettingsView().environmentObject(settingsViewModel) .eraseToAnyView())
    }
    
    var serversView: some View {
        SettingsItemView<AnyView>(imageName: "settings.servers",
                                  title: "Servers",
                                  destination:ServersListView().environmentObject(serversViewModel).eraseToAnyView())
    }
    
    var helpView: some View {
        SettingsItemView<AnyView>(imageName: "settings.help",
                                  title: LocalizableSettings.settAbout.localized,
                                  destination:AboutAndHelpView().environmentObject(settingsViewModel) .eraseToAnyView())
    }
}

struct SettingsMainView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMainView(appModel: MainAppModel())
    }
}
