//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum LocalizableSettings: String, LocalizableDelegate {
    
    case appBar = "Settings_AppBar"
    case settLanguage = "Settings_Sett_Language"
    case settLock = "Settings_Sett_Lock"
    case settAbout = "Settings_Sett_About"
    
    case settRecentFiles = "Settings_Sett_RecentFiles"
    case settRecentFilesExpl = "Settings_Sett_RecentFiles_Expl"
    
    case settScreenSecurity = "Settings_Sett_ScreenSecurity"
    case settScreenSecurityExpl = "Settings_Sett_ScreenSecurity_Expl"

    // About & Help
    case settAboutHead = "Settings_SettAbout_Head"
    case settAboutSubhead = "Settings_SettAbout_Subhead"
    case settAboutContactUs = "Settings_SettAbout_ContactUs"
    case settAboutPrivacyPolicy = "Settings_SettAbout_PrivacyPolicy"
    
    //Languages
    
    case settLangDefaultLanguage = "Settings_SettLang_DefaultLanguage"
    case settLangDefaultLanguageExpl = "Settings_SettLang_DefaultLanguage_Expl"

    case settLangEnglish = "Settings_SettLang_English_Expl"
    case settLangFrench = "Settings_SettLang_French_Expl"
    case settLangSpanish = "Settings_SettLang_Spanish_Expl"

    case settLockTimeout = "Settings_Sett_LockTimeout"
    case settLockTimeoutSheetTitle = "Settings_SettLockTimeout_SheetTitle"
    case settLockTimeoutSheetExpl = "Settings_SettLockTimeout_SheetExpl"
    case settLockTimeoutImmediatelySheetSelect = "Settings_SettLockTimeout_Immediately_SheetSelect"
    case settLockTimeoutOneminuteSheetSelect = "Settings_SettLockTimeout_Oneminute_SheetSelect"
    case settLockTimeoutFiveMinutesSheetSelect = "Settings_SettLockTimeout_FiveMinutes_SheetSelect"
    case settLockTimeoutThirtyMinutesSheetSelect = "Settings_SettLockTimeout_ThirtyMinutes_SheetSelect"
    case settLockTimeoutOneHourSheetSelect = "Settings_SettLockTimeout_OneHour_SheetSelect"
    case settLockTimeoutCancelSheetAction = "Settings_SettLockTimeout_Cancel_SheetAction"
    case settLockTimeoutSaveSheetAction = "Settings_SettLockTimeout_Save_SheetAction"
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
