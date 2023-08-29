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
    case arabic = "ar"
    case belarusian = "be"
    case persian = "fa"
    case kurdish = "ku"
    case burmese = "my"
    case tamil = "ta"

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
        case .arabic:
            return "ar"
        case .belarusian:
            return "be"
        case .persian:
            return "fa-IR"
        case .kurdish:
            return "ku"
        case .burmese:
            return "my"
        case .tamil:
            return "ta"
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
        case .arabic:
            return "العربية"
        case .belarusian:
            return "беларуская"
        case .persian:
            return "فارسی"
        case .kurdish:
            return "کوردی"
        case .burmese:
            return "မြန်မာ"
        case .tamil:
            return "தமிழ்"

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
        case .arabic:
            return LocalizableSettings.settLangArabic.localized
        case .belarusian:
            return LocalizableSettings.settLangBelarusian.localized
        case .persian:
            return LocalizableSettings.settLangPersian.localized
        case .kurdish:
            return LocalizableSettings.settLangKurdish.localized
        case .burmese:
            return LocalizableSettings.settLangBurmese.localized
        case .tamil:
            return LocalizableSettings.settLangTamil.localized
        }
    }
    
    var layoutDirection: LayoutDirection {
        
        switch self {
            
        case .systemLanguage:
            
            switch LanguageManager.shared.getSystemLanguageString() {
            case "ar", "fa", "ku":
                return .rightToLeft
            default:
                return .leftToRight
            }
        case .arabic, .kurdish, .persian :
            return .rightToLeft

        default:
            return .leftToRight
        }
    }
    
    var localeLanguage: Locale {
        return Locale(identifier: code)
    }
}
