//
//  Validator.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

struct Regex {
    static let passwordLength = "^.{6,}"
    static let textLength = "^.{3,}"
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
        guard validateRegex(value: self, pattern: Regex.passwordLength) else {
            return false
        }
        return true
    }
}

extension String {
    func textValidator() -> Bool {
        guard !self.isEmpty else {
            return false
        }
        guard validateRegex(value: self, pattern: Regex.textLength) else {
            return false
        }
        return true
    }
}

