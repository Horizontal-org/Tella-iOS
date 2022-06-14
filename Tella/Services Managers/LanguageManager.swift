//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class LanguageManager {
    
    static var shared = LanguageManager()
    
    var currentLanguage : Language {
        set {
            UserDefaults.standard.set(newValue.code, forKey: languageKey)
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
    
    func getSystemLanguage() -> Language? {
        guard let languageString =  getSystemLanguageString() else { return nil }
        return Language(rawValue: languageString)
    }
    
    func getSystemLanguageString() -> String? {
        
        if let preferredLanguage = NSLocale.preferredLanguages.first?.split(separator: "-")  {
            if preferredLanguage.count > 0 {
                return String(preferredLanguage[0])
            }
        }
        return nil
    }
    
    func getDefaultLanguage() -> Language {
        guard let systemLanguage = getSystemLanguage() else { return Language.english }
        return systemLanguage
    }
}
