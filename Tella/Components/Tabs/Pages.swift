//
//  Pages.swift
//  Tella
//
//  Created by gus valbuena on 1/11/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

public enum Page: Hashable {
    
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
}
