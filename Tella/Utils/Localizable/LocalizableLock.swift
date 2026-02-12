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

    case onboardingRecordTitle = "Onboarding_Record_Title"
    case onboardingRecordExpl = "Onboarding_Record_Expl"
    case onboardingRecordInfo = "Onboarding_Record_Info"

    case onboardingFilesTitle = "Onboarding_Files_Title"
    case onboardingFilesExpl = "Onboarding_Files_Expl"
    case onboardingFilesInfo = "Onboarding_Files_Info"

    case onboardingConnectionsTitle = "Onboarding_Connections_Title"
    case onboardingConnectionspart1Expl = "Onboarding_Connections_part1_Expl"
    case onboardingConnectionspart2Expl = "Onboarding_Connections_part2_Expl"

    case onboardingConnectionsDropbox = "Onboarding_Connections_Dropbox"
    case onboardingConnectionsGDrive = "Onboarding_Connections_GDrive"
    case onboardingConnectionsNextcloud = "Onboarding_Connections_Nextcloud"
    case onboardingConnectionsUwazi = "Onboarding_Connections_Uwazi"
    case onboardingConnectionsTellaWeb = "Onboarding_Connections_TellaWeb"

    case onboardingNearbySharingTitle = "Onboarding_NearbySharing_Title"
    case onboardingNearbySharingExpl = "Onboarding_NearbySharing_Expl"

    case lockSuccessTitle = "LockUnlock_LockSuccess_Title"
    case lockSuccessExpl = "LockUnlock_LockSuccess_Expl"
    case lockSuccessLink = "LockUnlock_LockSuccess_Link"

    
    case protectLocksheetTitle = "LockUnlock_ProtectLock_SheetTitle"
    case protectLocksheetExpl = "LockUnlock_ProtectLock_SheetExpl"
    case protectLocksheetAction = "LockUnlock_ProtectLock_SheetAction"

    
    case onboardingLockDoneTitle = "Onboarding_LockDone_Title"
    case onboardingLockDoneExpl = "Onboarding_LockDone_Expl"
    case goToTella = "Onboarding_Done_Action_GoToTella"
    case advancedSettings = "Onboarding_LockDone_Action_AdvancedSettings"
    
    case onboardingServerDoneTitle = "Onboarding_ServerDone_Title"
    case onboardingServerDoneExpl = "Onboarding_ServerDone_Expl"

    case onboardingServerMainTitle = "Onboarding_ServerMain_Title"
    case onboardingServerMainExpl = "Onboarding_ServerMain_Expl"
    case onboardingServerMainSetupServer = "Onboarding_ServerMain_Action_SetupServer"
    case onboardingServerMainNoThanks = "Onboarding_ServerMain_Action_NoThanks"

    case onboardingServerConnectedTitle = "Onboarding_ServerConnected_Title"
    case onboardingServerConnectedExpl = "Onboarding_ServerConnected_Expl"

    case onboardingLoseFileWarningTitle = "Onboarding_LoseFileWarning_Title"
    case onboardingLoseFileWarningPart1Expl = "Onboarding_LoseFileWarning_part1_Expl"
    case onboardingLoseFileWarningPart2Expl = "Onboarding_LoseFileWarning_part2_Expl"

    
    case loseFileWarningUnderstand = "Onboarding_LoseFileWarning_Action_Understand"

    
    
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

