//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
    case russian = "ru"
    case portuguese = "pt"
    case vietnamese = "vi"
    case bangla = "bn"
    case indonesian = "id"
    case portugueseMozambique = "pt_MZ"
    case tsonga = "ts"
    case ndau = "sn-ZW"
    case azerbaijani = "az"

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
        case .russian:
            return "ru"
        case .portuguese:
            return "pt-BR"
        case .vietnamese:
            return "vi"
        case .bangla:
            return "bn"
        case .indonesian:
            return "id"
        case .portugueseMozambique:
            return "pt-MZ"
        case .tsonga:
            return "ts"
        case .ndau:
            return "sn-ZW"
        case .azerbaijani:
            return "az"
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
        case .russian:
            return "Русский"
        case .portuguese:
            return "Português"
        case .vietnamese:
            return "Tiếng Việt"
        case .bangla:
            return "বাংলা"
        case .indonesian:
            return "Bahasa Indonesia"
        case .portugueseMozambique:
            return "Moçambique Portuguesa"
        case .tsonga:
            return "Xitsonga"
        case .ndau:
            return "Ndau"
        case .azerbaijani:
            return "Azərbaycanca"
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
        case .russian:
            return LocalizableSettings.settLangRussian.localized
        case .portuguese:
            return LocalizableSettings.settLangPortuguese.localized
        case .vietnamese: 
            return LocalizableSettings.settLangVietnamese.localized
        case .bangla:
            return LocalizableSettings.settLangBangla.localized
        case .indonesian:
            return LocalizableSettings.settLangIndonesian.localized
        case .portugueseMozambique:
            return LocalizableSettings.settLangPortugueseMozambique.localized
        case .tsonga:
            return LocalizableSettings.settLangTsonga.localized
        case .ndau:
            return LocalizableSettings.settLangNdau.localized
        case .azerbaijani:
            return LocalizableSettings.settLangAzerbaijani.localized
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
