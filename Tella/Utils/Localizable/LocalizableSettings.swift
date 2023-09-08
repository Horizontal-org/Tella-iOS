//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum LocalizableSettings: String, LocalizableDelegate {
    
    
    case settAppBar = "Settings_Sett_AppBar"
    
    // Main
    case settGeneral = "Settings_Sett_General"
    case settServers = "Settings_Sett_Servers"
    case settSecurity = "Settings_Sett_Security"
    case settAbout = "Settings_Sett_About"
    
    // General
    case settGenAppBar = "Settings_SettGen_AppBar"
    case settGenLanguage = "Settings_SettGen_Language"
    case settGenRecentFiles = "Settings_SettGen_RecentFiles"
    case settGenRecentFilesExpl = "Settings_SettGen_RecentFiles_Expl"
    
    // Language
    case settLangAppBar = "Settings_SettLang_AppBar"
    case settLangDefaultLanguage = "Settings_SettLang_DefaultLanguage"
    case settLangDefaultLanguageExpl = "Settings_SettLang_DefaultLanguage_Expl"
    
    case settLangEnglish = "Settings_SettLang_English_Expl"
    case settLangFrench = "Settings_SettLang_French_Expl"
    case settLangSpanish = "Settings_SettLang_Spanish_Expl"
    case settLangArabic = "Settings_SettLang_Arabic_Expl"
    case settLangBelarusian = "Settings_SettLang_Belarusian_Expl"
    case settLangPersian = "Settings_SettLang_Persian_Expl"
    case settLangKurdish = "Settings_SettLang_Kurdish_Expl"
    case settLangBurmese = "Settings_SettLang_Burmese_Expl"
    case settLangTamil = "Settings_SettLang_Tamil_Expl"

    // Security
    
    case settSecAppBar = "Settings_SettSec_AppBar"
    case settSecLock = "Settings_SettSec_Lock"
    case settSecLockTimeout = "Settings_SettSec_LockTimeout"
    case settSecDeleteAfterFail = "Settings_SettSec_DeleteAfterFail"
    case settSecShowUnlockAttempts = "Settings_SettSec_ShowUnlockAttempts"
    case settSecShowUnlockAttemptsExpl = "Settings_SettSec_ShowUnlockAttempts_Expl"
    case settSecScreenSecurity = "Settings_SettSec_ScreenSecurity"
    case settSecScreenSecurityExpl = "Settings_SettSec_ScreenSecurity_Expl"
    case settQuickDelete = "Settings_Sett_QuickDelete"
    case settQuickDeleteExpl = "Settings_Sett_QuickDelete_Expl"
    case settQuickDeleteFilesCheckbox = "Settings_Sett_QuickDelete_Files_CheckboxItem"
    case settQuickDeleteConnectionsCheckbox = "Settings_Sett_QuickDelete_Connections_CheckboxItem"
    case settSecPreserveMetadata = "Setting_SettSec_PreserveMetadata"
    case settSecPreserveMetadataExpl = "Setting_SettSec_PreserveMetadata_Expl"


    
    // LockTimeout
    case settLockTimeoutSheetTitle = "Settings_SettLockTimeout_SheetTitle"
    case settLockTimeoutSheetExpl = "Settings_SettLockTimeout_SheetExpl"
    case settLockTimeoutImmediatelySheetSelect = "Settings_SettLockTimeout_Immediately_SheetSelect"
    case settLockTimeoutOneminuteSheetSelect = "Settings_SettLockTimeout_Oneminute_SheetSelect"
    case settLockTimeoutFiveMinutesSheetSelect = "Settings_SettLockTimeout_FiveMinutes_SheetSelect"
    case settLockTimeoutThirtyMinutesSheetSelect = "Settings_SettLockTimeout_ThirtyMinutes_SheetSelect"
    case settLockTimeoutOneHourSheetSelect = "Settings_SettLockTimeout_OneHour_SheetSelect"
    case settLockTimeoutCancelSheetAction = "Settings_SettLockTimeout_Cancel_SheetAction"
    case settLockTimeoutSaveSheetAction = "Settings_SettLockTimeout_Save_SheetAction"

    // DeleteAfterFail
    case settDeleteAfterFailOffTitle = "Settings_SettSec_DeleteAfterFail_Off"
    case settDeleteAfterFailSheetTitle = "Settings_SettDeleteAfterFail_SheetTitle"
    case settDeleteAfterFailSheetExpl = "Settings_SettDeleteAfterFail_SheetExpl"
    case settDeleteAfterFailOffSheetSelect = "Settings_SettDeleteAfterFail_Off_SheetSelect"
    case settDeleteAfterFailFiveAttemptsSheetSelect = "Settings_SettDeleteAfterFail_FiveAttempts_SheetSelect"
    case settDeleteAfterFailTenAttemptsSheetSelect = "Settings_SettDeleteAfterFail_TenAttempts_SheetSelect"
    case settDeleteAfterFailTwentyAttemptsSheetSelect = "Settings_SettDeleteAfterFail_TwentyAttempts_SheetSelect"
    case settDeleteAfterFailCancelSheetAction = "Settings_SettDeleteAfterFail_Cancel_SheetAction"
    case settDeleteAfterFailSaveSheetAction = "Settings_SettDeleteAfterFail_Save_SheetAction"
    case settDeleteAfterFailToast = "Settings_SettDeleteAfterFail_Toast"
    case settDeleteAfterFailOffToast = "Settings_SettDeleteAfterFail_Off_Toast"
    
    // Servers
    case settServersAppBar = "Settings_SettServers_AppBar"
    case settServerSelectionTitle = "Setting_SettServer_Selection_Title"
    case settServerSelectionMessage = "Setting_SettServer_Selection_Message"
    case settServerTellaWeb = "Setting_SettServer_TellaWeb"
    case settServerUwazi = "Setting_SettServer_Uwazi"

    // Uwazi
    case UwaziServerURL = "Setting_Server_Uwazi_Server_URL"
    case UwaziAccessServerTitle = "Setting_Server_Uwazi_Access_Title"
    case UwaziLogin = "Setting_Server_Uwazi_Login"
    case UwaziPublicInstance = "Setting_Server_Uwazi_Access_Public"
    case UwaziLoginAccess = "Setting_Server_Uwazi_Login_Access"
    case UwaziUsername = "Setting_Server_Uwazi_Username"
    case UwaziPassword = "Setting_Server_Uwazi_Password"
    case UwaziTwoStepTitle = "Setting_Server_Uwazi_Two_Step_Title"
    case UwaziTwoStepMessage = "Setting_Server_Uwazi_Two_Step_Message"
    case UwaziAuthenticationPlaceholder = "Setting_Server_Uwazi_Authentication_Placeholder"
    case UwaziAuthenticationVerify = "Setting_Server_Uwazi_Authentication_Verify"
    case UwaziLanguageTitle = "Setting_Server_Uwazi_Language_Title"
    case UwaziLanguageMessage = "Setting_Server_Uwazi_Language_Message"
    case UwaziLanguageOk = "Setting_Server_Uwazi_Language_Ok"
    case UwaziLanguageCancel = "Setting_Server_Uwazi_Language_Cancel"
    case UwaziSuccess = "Setting_Server_Uwazi_Connect_Server"
    case UwaziSuccessMessage = "Setting_Server_Uwazi_Success_Message"
    
    // About & Help
    
    case settAboutAppBar = "Settings_SettAbout_AppBar"
    case settAboutHead = "Settings_SettAbout_Head"
    case settAboutSubhead = "Settings_SettAbout_Subhead"
    case settAboutContactUs = "Settings_SettAbout_ContactUs"
    case settAboutPrivacyPolicy = "Settings_SettAbout_PrivacyPolicy"
}


protocol LocalizableDelegate {
    var rawValue: String { get }
    var table: String? { get }
    var localized: String { get }
}

extension LocalizableDelegate {
    
    var localized: String {
        return Bundle.main.localizedString(forKey: rawValue, value: nil, table: table)
    }
    
    var table: String? {
        return "Localizable"
    }
}
