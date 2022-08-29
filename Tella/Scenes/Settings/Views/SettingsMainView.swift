//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsMainView: View {
    
    @EnvironmentObject var appModel : MainAppModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var settingsViewModel : SettingsViewModel
    
    var cards : [CardData<AnyView>]  { return [CardData(imageName: "settings.general",
                                                        title: "General",
                                                        cardType : .display,
                                                        cardName: MainSettingsCardName.general,
                                                        destination: GeneralView().eraseToAnyView()),
                                               CardData(imageName: "settings.lock",
                                                        title: "Security",
                                                        cardType : .display,
                                                        cardName: MainSettingsCardName.security,
                                                        destination: SecuritySettingsView().eraseToAnyView()),
                                               CardData(imageName: "settings.servers",
                                                        title: "Servers",
                                                        cardType : .display,
                                                        cardName: MainSettingsCardName.security),
                                               CardData(imageName: "settings.help",
                                                        title: LocalizableSettings.settAbout.localized,
                                                        cardType : .display,
                                                        cardName: MainSettingsCardName.aboutAndHelp,
                                                        destination: AboutAndHelpView().eraseToAnyView() )] }
    
    init(appModel:MainAppModel) {
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(appModel: appModel))
    }
    
    var body: some View {
        ContainerView {
            VStack( spacing: 12) {
                if appModel.shouldUpdateLanguage {
                    
                    Spacer()
                        .frame(height: 12)
                    
                    SettingsCardView(cardDataArray: cards)
                    
                    Spacer()
                }
            }
        }
        .environmentObject(settingsViewModel)
        
        .toolbar {
            LeadingTitleToolbar(title: LocalizableSettings.settAppBar.localized)
        }
        
        .onDisappear(perform: {
            appModel.saveSettings()
        })
        
        .onDisappear {
            appModel.publishUpdates()
        }
    }
}

struct SettingsMainView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMainView(appModel: MainAppModel())
    }
}
