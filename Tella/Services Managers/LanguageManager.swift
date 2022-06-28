//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class LanguageManager {
    
    static var shared = LanguageManager()
    
    var currentLanguage : Language {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: languageKey)
            UserDefaults.standard.synchronize()
            
            Bundle.setLanguage(newValue.code)
            
        } get {
            if let languageCode = UserDefaults.standard.string(forKey: languageKey),
               let language = Language(rawValue: languageCode) {
                return language
            } else {
                self.currentLanguage = .systemLanguage
                return .systemLanguage
            }
        }
    }
    
    func getSystemLanguage() -> Language {
        guard let languageString =  getSystemLanguageString() else { return Language.systemLanguage }
        return Language(rawValue: languageString) ?? Language.systemLanguage
    }
    
    func getSystemLanguageString() -> String? {
        
        if let preferredLanguage = NSLocale.preferredLanguages.first?.split(separator: "-")  {
            if preferredLanguage.count > 0 {
                return String(preferredLanguage[0])
            }
        }
        return nil
    }
}
