//
//  DeleteAfterFailOption.swift
//  Tella
//
//  Created by Gustavo on 10/07/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

enum DeleteAfterFailOption : String {
    case off
    case five
    case ten
    case twenty
    
    var displayName: String {
        switch self {
        case .off:
            return LocalizableSettings.settDeleteAfterFailOffSheetSelect.localized
        case .five:
            return LocalizableSettings.settDeleteAfterFailFiveAttemptsSheetSelect.localized
        case .ten:
            return LocalizableSettings.settDeleteAfterFailTenAttemptsSheetSelect.localized
        case .twenty:
            return LocalizableSettings.settDeleteAfterFailTwentyAttemptsSheetSelect.localized
        }
    }
    
    var selectedDisplayName: String {
        switch self {
        case .off:
            return LocalizableSettings.settDeleteAfterFailOffTitle.localized
        default:
            return self.displayName
        }
    }
    
    var numberOfAttempts: Int {
        switch self{
        case .off:
            return 0
        case .five:
            return 5
        case .ten:
            return 10
        case .twenty:
            return 20
        }
    }
}
