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
    case spanishLatinAmerican = "es-419"
    case french = "fr"
    case arabic = "ar"
    case belarusian = "be"
    case persian = "fa"
    case kurdish = "ku"
    case burmese = "my"

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
        case .spanishLatinAmerican:
            return "es-419"
        case .arabic:
            return "ar"
        case .belarusian:
            return "be"
        case .persian:
            return "fa"
        case .kurdish:
            return "ku"
        case .burmese:
            return "my"
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
        case .spanishLatinAmerican:
            return "Español latinoamericano"
        case .arabic:
            return "العربية"
        case .belarusian:
            return "беларуская"
        case .persian:
            return "فارسی"
        case .kurdish:
            return "ku"
        case .burmese:
            return "မြန်မာ"

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
        case .spanishLatinAmerican:
            return LocalizableSettings.settLangSpanishLatinAmerican.localized
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
