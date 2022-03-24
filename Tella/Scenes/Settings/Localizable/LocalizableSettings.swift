//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum LocalizableSettings: String, LocalizableDelegate {
    
    case  title = "SettingsTitle"
    case  language = "SettingsLanguage"
    case  lock = "SettingsLock"
    case  aboutAndHelp = "SettingsAboutAndHelp"
    
    // About & Help
    case  version = "SettingsVersion"
    case  contactUs = "SettingsContactUs"
    case  privacyPolicy = "SettingsPrivacyPolicy"
    
    var tableName: String? {
        return "Settings"
    }
}
