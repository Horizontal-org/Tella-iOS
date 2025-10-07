//
//  LocalizableApp.swift
//  Tella
//
//   
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

enum LocalizableLock: String, LocalizableDelegate {
    
    // Onboarding
    
    // Intro
    case onboardingIntroHead = "Onboarding_Intro_Head"
    case onboardingIntroSubhead = "Onboarding_Intro_Subhead"
    case onboardingIntroActionGetStarted = "Onboarding_Intro_Action_GetStarted"

    case onboardingCameraTitle = "Onboarding_Camera_Title"
    case onboardingCameraExpl = "Onboarding_Camera_Expl"

    case onboardingRecorderTitle = "Onboarding_Recorder_Title"
    case onboardingRecorderExpl = "Onboarding_Recorder_Expl"
    case onboardingEncryptedFilesFoldersTitle = "Onboarding_EncryptedFilesFolders_Title"
    case onboardingEncryptedFilesFoldersExpl = "Onboarding_EncryptedFilesFolders_Expl"
    case onboardingServerConnectionsTitle = "Onboarding_ServerConnections_Title"
    case onboardingServerConnectionspart1Expl = "Onboarding_ServerConnections_part1_Expl"
    case onboardingServerConnectionspart2Expl = "Onboarding_ServerConnections_part2_Expl"
    case onboardingNearbySharingTitle = "Onboarding_NearbySharing_Title"
    case onboardingNearbySharingExpl = "Onboarding_NearbySharing_Expl"

    case onboardingLockSuccessTitle = "Onboarding_LockSuccess_Title"
    case onboardingLockSuccessExpl = "Onboarding_LockSuccess_Expl"
    
    case onboardingLockDoneTitle = "Onboarding_LockDone_Title"
    case onboardingLockDoneExpl = "Onboarding_LockDone_Expl"
    case goToTella = "Onboarding_Done_Action_GoToTella"
    case advancedSettings = "Onboarding_LockDone_Action_AdvancedSettings"
    
    case onboardingServerDoneTitle = "Onboarding_ServerDone_Title"
    case onboardingServerDoneExpl = "Onboarding_ServerDone_Expl"

    case onboardingServerMainTitle = "Onboarding_ServerMain_Title"
    case onboardingServerMainExpl = "Onboarding_ServerMain_Expl"
    case onboardingServerMainConnectServer = "Onboarding_ServerMain_Action_ConnectServer"
    case onboardingServerMainContinue = "Onboarding_ServerMain_Action_Continue"

    case onboardingServerConnectedTitle = "Onboarding_ServerConnected_Title"
    case onboardingServerConnectedExpl = "Onboarding_ServerConnected_Expl"

    
    // Lock Select view
    case lockSelectSubhead = "LockUnlock_LockSelect_Subhead"
    case lockSelectActionPassword = "LockUnlock_LockSelect_Action_Password"
    case lockSelectActionExplPassword = "LockUnlock_LockSelect_ActionExpl_Password"
    case lockSelectActionPin = "LockUnlock_LockSelect_Action_Pin"
    case lockSelectActionExplPin = "LockUnlock_LockSelect_ActionExpl_Pin"
    case lockSelectTitle = "LockUnlock_LockSelect_Title"
    
    case actionBack = "LockUnlock_Action_Back"
    case actionNext = "LockUnlock_Action_Next"
    
    // Lock Password view
    case lockPasswordSetSubhead = "LockUnlock_LockPasswordSet_Subhead"
    case lockPasswordSetExpl = "LockUnlock_LockPasswordSet_Expl"
    case lockPasswordConfirmSubhead = "LockUnlock_LockPasswordConfirm_Subhead"
    case lockPasswordConfirmExpl = "LockUnlock_LockPasswordConfirm_Expl"
    case lockPasswordConfirmErrorPasswordsDoNotMatch = "LockUnlock_LockPasswordConfirm_Error_PasswordsDoNotMatch"
    
    // Lock Pin view
    case lockPinSetSubhead = "LockUnlock_LockPinSet_Subhead"
    case lockPinSetExpl = "LockUnlock_LockPinSet_Expl"
    case lockPinConfirmSubhead = "LockUnlock_LockPinConfirm_Subhead"
    case lockPinConfirmExpl = "LockUnlock_LockPinConfirm_Expl"
    case lockPinConfirmErrorPINsDoNotMatch = "LockUnlock_LockPinConfirm_Error_PINsDoNotMatch"
    
    // Unlock Password view
    case unlockPasswordSubhead = "LockUnlock_UnlockPassword_Subhead"
    case unlockUpdatePasswordSubhead = "LockUnlock_UnlockUpdatePassword_Subhead"
    case unlockUpdatePasswordErrorIncorrectPassword = "LockUnlock_UnlockUpdatePassword_Error_IncorrectPassword"
    
    // Unlock Pin view
    case unlockPinSubhead = "LockUnlock_UnlockPin_Subhead"
    case unlockUpdatePinErrorIncorrectPIN = "LockUnlock_UnlockUpdatePin_Error_IncorrectPIN"
    case unlockUpdatePinSubhead = "LockUnlock_UnlockUpdatePin_Subhead"

    // Delete After Faile
    case unlockDeleterAfterFailRemainingAttempts = "LockUnlock_UnlockDeleteAfterFail_Warning_RemainingAttempts"
    case unlockDeleteAfterFailContentDeleted = "LockUnlock_UnlockDeleteAfterFail_Error_ContentDeleted"
}

