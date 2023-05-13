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
    
    // Security
    
    case settSecAppBar = "Settings_SettSec_AppBar"
    case settSecLock = "Settings_SettSec_Lock"
    case settSecLockTimeout = "Settings_SettSec_LockTimeout"
    case settSecScreenSecurity = "Settings_SettSec_ScreenSecurity"
    case settSecScreenSecurityExpl = "Settings_SettSec_ScreenSecurity_Expl"
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
    
    // Servers
    case settServersAppBar = "Settings_SettServers_AppBar"
    
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
