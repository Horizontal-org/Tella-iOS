//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation


class SettingsViewModel: ObservableObject {
    
    @Published var languageItems : [Language]
    
    var aboutAndHelpItems : [AboutAndHelpItem] = {
        return [AboutAndHelpItem(title: LocalizableSettings.contactUs.localized,
                                 imageName: "settings.contact-us",
                                 url: TellaUrls.contactURL),
                AboutAndHelpItem(title: LocalizableSettings.privacyPolicy.localized,
                                 imageName: "settings.privacy",
                                 url: TellaUrls.privacyURL)
        ]
    }()
    
    init() {
        languageItems = Language.allCases.map {$0}
    }
}

struct AboutAndHelpItem :Hashable {
    var title : String
    var imageName : String
    var url : String
}


