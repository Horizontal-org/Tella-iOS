//
//  LocalizableApp.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation


extension Localizable {
    
    struct Lock  {
        
        static var backButtonTitle = "LockBackButtonTitle".localized
        static var nextButtonTitle = "LockNextButtonTitle".localized

        // Lock Choice view
        static var choiceTitle = "LockChoiceTitle".localized
        static var passwordButtonTitle = "LockChoicePasswordButtonTitle".localized
        static var passwordButtonDescription = "LockChoicePasswordButtonDescription".localized
        static var pinButtonTitle = "LockChoicePINButtonTitle".localized
        static var pinButtonDescription = "LockChoicePINButtonDescription".localized
        static var lockChoiceHeaderTitle = "LockChoiceHeaderTitle".localized

    // Lock Password view
        static var passwordTitle = "LockPasswordTitle".localized
        static var passwordDescription = "LockPasswordDescription".localized
        static var confirmPasswordTitle = "LockConfirmPasswordTitle".localized
        static var confirmPasswordDescription = "LockConfirmPasswordDescription".localized
        static var confirmPasswordError = "LockConfirmPasswordError".localized
    
    // Welcome view
        static var welcomeTitle = "LockWelcomeTitle".localized
        static var welcomeDescription = "LockWelcomeDescription".localized
        static var welcomeButtonTitle = "LockWelcomeButtonTitle".localized
    
    // Onboarding End view
        static var onboardingEndTitle = "LockOnboardingEndTitle".localized
        static var onboardingEndDescription = "LockOnboardingEndDescription".localized
        static var onboardingEndButtonTitle = "LockOnboardingEndButtonTitle".localized

    // Lock Pin view
        static var pinTitle = "LockPinTitle".localized
        static var pinDescription = "LockPinDescription".localized
        static var confirmPinTitle = "LockConfirmPinTitle".localized
        static var confirmPinDescription = "LockConfirmPinDescription".localized
    
    // Unlock Password view
        static var unlockPasswordTitle = "UnlockPasswordTitle".localized
        static var unlockPasswordError = "UnlockPasswordError".localized
        static var unlockUpdatePasswordTitle = "UnlockUpdatePasswordTitle".localized

    
    // Unlock Pin view
        static var unlockPinTitle = "UnlockPinTitle".localized
        static var unlockPinError = "UnlockPinError".localized
        static var unlockUpdatePinTitle = "UnlockUpdatePinTitle".localized
    }

}

struct Localizable {
 
}

extension String {
    var bundle: Bundle {
        return Bundle.main
    }

    var localized: String {
        return bundle.localizedString(forKey: self, value: nil, table: "Localizable")
    }
}
 
