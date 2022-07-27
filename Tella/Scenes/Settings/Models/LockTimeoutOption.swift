//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
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
            return "Immediately"
        case .oneMinute:
            return "1 minute"
        case .fiveMinutes:
            return "5 minutes"
        case .thirtyMinutes:
            return "30 minutes"
        case .onehour:
            return "1 hour"
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
