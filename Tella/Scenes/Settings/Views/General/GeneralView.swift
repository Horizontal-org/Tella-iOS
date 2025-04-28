//
//  GeneralView.swift
//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct GeneralView: View {
    
    @EnvironmentObject var appModel : MainAppModel
    @EnvironmentObject var settingsModel : SettingsModel
    @EnvironmentObject var appViewState : AppViewState
    
    @State private var presentingLanguage = false
    
    var body: some View {
        
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
        .fullScreenCover(isPresented: $presentingLanguage) {
            
        } content: {
            LanguageListView(isPresented: $presentingLanguage)
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableSettings.settGenAppBar.localized)
    }
    
    var contentView: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 8)
            
            SettingsCardView(cardViewArray: [languageView.eraseToAnyView()])
            
            SettingsCardView(cardViewArray: [recentFilesView.eraseToAnyView()])
            
            Spacer()
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
