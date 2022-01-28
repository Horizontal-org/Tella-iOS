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
    
    var code : String {
        
        switch self {
            
        case .english:
            return "en"
        }
    }
    
    var name : String {
        
        switch self {
            
        case .english:
            return "English"
        }
    }
    
    var englishName : String {
        
        switch self {
            
        case .english:
            return "English"
        }
    }
    
    var layoutDirection: LayoutDirection {
        
        switch self {
            
        default:
            return .leftToRight
        }
    }
    
    var localeLanguage: Locale {
        switch self {
            
        case .english:
            return Locale(identifier: "en")
        }
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
            
            guard let languagee = Language(rawValue: preferredLanguage) else { return Language.english }
            
            return languagee
        }
    }
    return Language.english
}
