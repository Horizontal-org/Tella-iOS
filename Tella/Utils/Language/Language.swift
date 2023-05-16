//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

let languageKey = "language"
let appleLanguages = "AppleLanguages"

enum Language: String, CaseIterable {
    
    case systemLanguage = "system"
    case english = "en"
    case spanish = "es"
    case french = "fr"
    
    var code : String {
        switch self {
        case .systemLanguage:
            return LanguageManager.shared.getSystemLanguageString() ?? "en"
        case .english:
            return "en"
        case .french:
            return "fr"
        case .spanish:
            return "es"
        }
    }
    
    var name : String {
        switch self {
        case .systemLanguage:
            return LocalizableSettings.settLangDefaultLanguage.localized
        case .english:
            return "English"
        case .french:
            return "Français"
        case .spanish:
            return "Español"
        }
    }
    
    var translatedName : String {
        switch self {
        case .systemLanguage:
            return LocalizableSettings.settLangDefaultLanguageExpl.localized
        case .english:
            return LocalizableSettings.settLangEnglish.localized
        case .french:
            return LocalizableSettings.settLangFrench.localized
        case .spanish:
            return LocalizableSettings.settLangSpanish.localized
        }
    }
    
    var layoutDirection: LayoutDirection {
        
        switch self {
            
        default:
            return .leftToRight
        }
    }
    
    var localeLanguage: Locale {
        return Locale(identifier: code)
    }
}
