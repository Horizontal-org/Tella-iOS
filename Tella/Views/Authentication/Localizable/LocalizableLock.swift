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
    case  lockChoiceHeaderTitle = "LockChoiceHeaderTitle"

    
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
    
    // Unlock Password view
    case  unlockPasswordTitle = "UnlockPasswordTitle"
    case  unlockPasswordError = "UnlockPasswordError"
    case  unlockUpdatePasswordTitle = "UnlockUpdatePasswordTitle"

    
    // Unlock Pin view
    case  unlockPinTitle = "UnlockPinTitle"
    case  unlockPinError = "UnlockPinError"
    case  unlockUpdatePinTitle = "UnlockUpdatePinTitle"

    var tableName: String? {
        return "Lock"
    }
}
