//
//  LocalizableApp.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

enum LocalizableLock: String, LocalizableDelegate {

    // Onboarding
    
    // Intro
    case onboardingIntroHead = "Onboarding_Intro_Head"
    case onboardingIntroExpl = "Onboarding_Intro_Expl"
    case onboardingIntroActionGetStarted = "Onboarding_Intro_Action_GetStarted"
    
    // Done
    case onboardingdLockSuccessHead = "Onboarding_LockSuccess_Head"
    case onboardingLockSuccessExpl = "Onboarding_LockSuccess_Expl"
    case onboardingLockSuccessActionGoToTella = "Onboarding_LockSuccess_Action_GoToTella"
    
    // Lock Pin view
    
    case lockPinSetBannerExpl = "LockUnlock_LockPinSet_BannerExpl"
    case lockPinConfirmBannerExpl = "LockUnlock_LockPinConfirm_BannerExpl"
    case lockUnlockLockPinUpdateBannerExpl = "LockUnlock_LockPinUpdate_BannerExpl"
    
    case lockUnlockUnlockPinUpdateBannerExpl = "LockUnlock_UnlockPinUpdate_BannerExpl"
    
    case errorPinLengthBannerExpl = "LockUnlock_Error_PinLength_BannerExpl"
    case errorPinDigitsBannerExpl = "LockUnlock_Error_PinDigits_BannerExpl"
    case errorPINsDoNotMatchBannerExpl = "LockUnlock_Error_PINsDoNotMatch_BannerExpl"
    case errorIncorrectPINBannerExpl = "LockUnlock_Error_IncorrectPIN_BannerExpl"
}

