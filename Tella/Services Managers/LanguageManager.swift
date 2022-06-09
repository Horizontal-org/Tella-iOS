//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

let languageKey = "language"
let appleLanguages = "AppleLanguages"

enum Language: String, CaseIterable {
    
    case english = "en"
    case frensh = "fr"
    case spanish = "es"

    var code : String {
        
        switch self {
        case .english:
            return "en"
        case .frensh:
            return "fr"
        case .spanish:
            return "es"

        }
    }
    
    var name : String {
        switch self {
        case .english:
            return "English"
        case .frensh:
            return "Français"
        case .spanish:
            return "Español"
        }
    }
    
    var translatedName : String {
        switch self {
        case .english:
            return LocalizableSettings.settLangEnglish.localized
        case .frensh:
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
    
    static var currentLanguage : Language {
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue.code) {
                UserDefaults.standard.set(encoded, forKey: languageKey)
            }
            
            UserDefaults.standard.set([newValue.code], forKey: appleLanguages)
            UserDefaults.standard.synchronize()
            
            Bundle.setLanguage(newValue.code)
            
        } get {
            
            if let languageCode = UserDefaults.standard.string(forKey: languageKey),
               let language = Language(rawValue: languageCode) {
                return language
            } else {
                
                return getDefaultLanguage()
            }
        }
    }
}

func getDefaultLanguage() -> Language {
    
    if let preferredLanguage = NSLocale.preferredLanguages.first?.split(separator: "-")  {
        if preferredLanguage.count > 0 {
            
            let preferredLanguage = String(preferredLanguage[0])
            
            guard let language = Language(rawValue: preferredLanguage) else { return Language.english }
            
            return language
        }
    }
    return Language.english
}
