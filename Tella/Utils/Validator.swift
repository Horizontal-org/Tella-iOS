//
//  Validator.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

struct Regex {
    static let passwordRegex = "^.{6,}"
    static let textRegex = "^.{1,}"
    static let usernameRegex = "^.{3,}"
    static let urlRegex = #"^(https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,3}|www\.[^\s]+\.[^\s]{2,3})$"#
}

func validateRegex(value: String, pattern:String) -> Bool {
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return !regex.notMatchedIn(value: value)
    } catch {
        return false
    }
}

extension String {
    
    func passwordValidator() -> Bool {
        guard !self.isEmpty else {
            return false
        }
        guard validateRegex(value: self, pattern: Regex.passwordRegex) else {
            return false
        }
        return true
    }

    func textValidator() -> Bool {
        guard !self.isEmpty else {
            return false
        }
        guard validateRegex(value: self, pattern: Regex.textRegex) else {
            return false
        }
        return true
    }
    
    func urlValidator() -> Bool {
        guard !self.isEmpty else {
            return false
        }
        guard validateRegex(value: self, pattern: Regex.urlRegex) else {
            return false
        }
        return true
    }

    func usernameValidator() -> Bool {
        guard !self.isEmpty else {
            return false
        }
        guard validateRegex(value: self, pattern: Regex.usernameRegex) else {
            return false
        }
        return true
    }

}

