//
//  DeleteAfterFailOption.swift
//  Tella
//
//  Created by Gustavo on 10/07/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
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
            return "off"
        case .five:
            return "5 attempts"
        case .ten:
            return "10 attempts"
        case .twenty:
            return "20 attempts"
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
