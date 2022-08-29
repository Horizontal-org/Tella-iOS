//
//  GeneralView.swift
//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct GeneralView: View {

    var cards : [[CardData<AnyView>]] {
        
        return [[CardData(imageName: "settings.language",
                          title: LocalizableSettings.settGenLanguage.localized,
                          value: LanguageManager.shared.currentLanguage.name,
                          cardType : .display,
                          cardName: GeneralCardName.language)],
                [CardData(title: LocalizableSettings.settGenRecentFiles.localized,
                          description: LocalizableSettings.settGenRecentFilesExpl.localized,
                          cardType : .toggle,
                          cardName: GeneralCardName.recentFile,
                          valueToSave: $appModel.settings.showRecentFiles)]]}
    
    @EnvironmentObject var appModel : MainAppModel
    @EnvironmentObject var settingsModel : SettingsModel
    
    @State private var presentingLanguage = false
    
    var body: some View {
        
        ContainerView {
            VStack( spacing: 12) {
                Spacer()
                    .frame(height: 12)
                
                ForEach(cards, id:\.self) { item in
                    SettingsCardView(cardDataArray: item) { card in
                        switch card {
                        case GeneralCardName.language:
                            presentingLanguage = true
                        default:
                            break
                        }
                    }
                }
                
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
}

struct GeneralView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView()
    }
}
