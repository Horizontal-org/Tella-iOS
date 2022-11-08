//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

public enum Pages: Hashable {
    
    case draft
    case outbox
    case submitted
    
    var title: String {
        switch self {
            
        case .draft:
            return "Drafts"
        case .outbox:
            return "Outbox"
        case .submitted:
            return "Submitted"
        }
    }
    
    static func fromHashValue(hashValue: Pages) -> Int {
        switch hashValue {
        case .draft:
            return 0
        case .outbox:
            return 1
        case .submitted:
            return 2
        }
    }
    
    static func fromValueHash(value: Int) -> Pages {
        switch value {
        case 0:
            return .draft
        case 1:
            return .outbox
        case 2:
            return .submitted
        default:
            return .draft
        }
    }
}
