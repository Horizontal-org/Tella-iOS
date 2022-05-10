//
//  LocalizableApp.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

extension Localizable {
    
    struct Lock {

        // Welcome view
        static var welcomeTitle = "LockWelcomeTitle".localized
        static var welcomeDescription = "LockWelcomeDescription".localized
        static var welcomeButtonTitle = "LockWelcomeButtonTitle".localized
        
        // Onboarding End view
        static var onboardingEndTitle = "LockOnboardingEndTitle".localized
        static var onboardingEndDescription = "LockOnboardingEndDescription".localized
        static var onboardingEndButtonTitle = "LockOnboardingEndButtonTitle".localized

        // Lock Pin view

        static var pinFirstMessage = "LockPinFirstMessage".localized
        static var pinDigitsError = "LockPinDigitsError".localized
        static var pinLengthError = "LockPinLengthError".localized

        static var confirmPinFirstMessage = "LockConfirmPinFirstMessage".localized
        static var confirmPinError = "LockConfirmPinError".localized

        static var updatePinFirstMessage = "LockUpdatePinFirstMessage".localized

        // Unlock Pin view

        static var unlockPinError = "UnlockPinError".localized
        static var unlockUpdatePinFirstMessage = "UnlockUpdatePinFirstMessage".localized
    }
}
