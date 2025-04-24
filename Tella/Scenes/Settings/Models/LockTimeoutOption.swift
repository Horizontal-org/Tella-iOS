//  Tella
//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import Foundation

enum LockTimeoutOption : String {
    
    case immediately
    case oneMinute
    case fiveMinutes
    case thirtyMinutes
    case onehour
    
    var displayName: String {
        
        switch self {
        case .immediately:
            return LocalizableSettings.settLockTimeoutImmediatelySheetSelect.localized
        case .oneMinute:
            return LocalizableSettings.settLockTimeoutOneminuteSheetSelect.localized
        case .fiveMinutes:
            return LocalizableSettings.settLockTimeoutFiveMinutesSheetSelect.localized
        case .thirtyMinutes:
            return LocalizableSettings.settLockTimeoutThirtyMinutesSheetSelect.localized
        case .onehour:
            return LocalizableSettings.settLockTimeoutOneHourSheetSelect.localized
        }
    }
    
    var time: Int {
        switch self {
        case .immediately:
            return 0
        case .oneMinute:
            return 60
        case .fiveMinutes:
            return 60 * 5
        case .thirtyMinutes:
            return 60 * 30
        case .onehour:
            return 60 * 60
        }
    }
}
