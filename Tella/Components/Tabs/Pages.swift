//
//  Pages.swift
//  Tella
//
//  Created by gus valbuena on 1/11/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

public enum Pages: Hashable {
    
    case draft
    case outbox
    case submitted
    case template
    
    var title: String {
        switch self {
            
        case .draft:
            return "Drafts"
        case .outbox:
            return "Outbox"
        case .submitted:
            return "Submitted"
        case .template:
            return "Template"
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
        case .template:
            return 3
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
        case 3:
            return .template
        default:
            return .draft
        }
    }
}
