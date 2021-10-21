//
//  LocalizableApp.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

enum LocalizableLock: String, LocalizableDelegate {
    
    // Lock Choice view
    case  title = "LockChoiceTitle"
    case  passwordButtonTitle = "LockChoicePasswordButtonTitle"
    case  passwordButtonDescription = "LockChoicePasswordButtonDescription"
    case  pinButtonTitle = "LockChoicePINButtonTitle"
    case  pinButtonDescription = "LockChoicePINButtonDescription"
    
    // Lock Password view
    case  passwordTitle = "LockPasswordTitle"
    case  passwordDescription = "LockPasswordDescription"
    case  confirmPasswordTitle = "LockConfirmPasswordTitle"
    case  confirmPasswordDescription = "LockConfirmPasswordDescription"
    case  confirmPasswordError = "LockConfirmPasswordError"
    
    // Lock Pin view
    case  pinTitle = "LockPinTitle"
    case  pinDescription = "LockPinDescription"
    case  confirmPinTitle = "LockConfirmPinTitle"
    case  confirmPinDescription = "LockConfirmPinDescription"
    
    var tableName: String? {
        return "Lock"
    }
}
