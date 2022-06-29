//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class SettingsViewModel: ObservableObject {
    
    @Published var languageItems : [Language] = []
    
    var aboutAndHelpItems : [AboutAndHelpItem] = {
        return [AboutAndHelpItem(title: LocalizableSettings.settAboutContactUs.localized,
                                 imageName: "settings.contact-us",
                                 url: TellaUrls.contactURL),
                AboutAndHelpItem(title: LocalizableSettings.settAboutPrivacyPolicy.localized,
                                 imageName: "settings.privacy",
                                 url: TellaUrls.privacyURL)
        ]
    }()
    
    init() {
        
        languageItems = Language.allCases.map {$0}

        languageItems = languageItems.sorted(by: { $0.name < $1.name })
        
        if let index = languageItems.firstIndex(where: {$0 == .systemLanguage}) {
            languageItems = languageItems.rearrange(fromIndex: index, toIndex: 0)
        }
    }
}

struct AboutAndHelpItem :Hashable {
    var title : String
    var imageName : String
    var url : String
}


