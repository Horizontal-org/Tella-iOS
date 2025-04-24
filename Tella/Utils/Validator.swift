//
//  Validator.swift
//  Tella
//
//   
//  Copyright © 2021 HORIZONTAL. All rights reserved.
//

import Foundation

struct Regex {
    static let passwordRegex = "^.{6,}"
    static let textRegex = "^.{1,}"
    
    //    FolderNameRegex regex will:
    //    Allow: Non-empty strings containing at least one non-whitespace character that does not include / or \
    //    Disallow: Empty strings
    //              Strings that consist only of spaces
    //              Strings that contain / or \
    static let folderNameRegex = "^(?![ ]*$)(?!.*[\\/\\\\]).{1,}$"
    
    static let usernameRegex = "^.{3,}"
    static let urlRegex = #"^(http(s):\/\/.)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)$"#
    static let codeRegex = "^[0-9]{6,6}$"
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

    func codeValidator() -> Bool {
        guard !self.isEmpty else {
            return false
        }
        guard validateRegex(value: self, pattern: Regex.codeRegex) else { return false }
        return true
    }
    
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

    func folderNameValidator() -> Bool {
        guard !self.isEmpty else {
            return false
        }
        guard validateRegex(value: self, pattern: Regex.folderNameRegex) else {
            return false
        }
        return true
    }
}

