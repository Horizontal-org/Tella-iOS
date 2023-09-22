//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

public enum Pages: Hashable {
    
    case templates
    case draft
    case outbox
    case submitted
    
    var title: String {
        switch self {
            
        case .templates:
            return "Templates"
        case .draft:
            return "Drafts"
        case .outbox:
            return "Outbox"
        case .submitted:
            return "Submitted"
        }
    }
}
