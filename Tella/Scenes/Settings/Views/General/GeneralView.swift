//
//  GeneralView.swift
//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct GeneralView: View {
    
    @EnvironmentObject var appModel : MainAppModel
    @EnvironmentObject var settingsModel : SettingsModel
    @EnvironmentObject var appViewState : AppViewState
    
    @State private var presentingLanguage = false
    
    var body: some View {
        
        ContainerView {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 8)
                
                SettingsCardView(cardViewArray: [languageView.eraseToAnyView()])
                
                SettingsCardView(cardViewArray: [recentFilesView.eraseToAnyView()])
                
                Spacer()
            }
        }
        .toolbar {
            LeadingTitleToolbar(title: LocalizableSettings.settGenAppBar.localized)
        }
        .fullScreenCover(isPresented: $presentingLanguage) {
            
        } content: {
            LanguageListView(isPresented: $presentingLanguage)
        }
    }
    
    var languageView: some View {
        
        SettingsItemView<AnyView>(imageName: "settings.language",
                                  title: LocalizableSettings.settGenLanguage.localized,
                                  value: LanguageManager.shared.currentLanguage.name,
                                  destination:nil) {
            presentingLanguage = true
        }
    }
    
    var recentFilesView: some View {
        
        SettingToggleItem(title: LocalizableSettings.settGenRecentFiles.localized,
                          description: LocalizableSettings.settGenRecentFilesExpl.localized,
                          toggle: $appModel.settings.showRecentFiles)
    }
    
}

struct GeneralView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView()
    }
}
