//
//  ResourceCardType.swift
//  Tella
//
//  Created by gus valbuena on 2/29/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

enum ResourceCardType {
    case save
    case more
    
    var imageName: String {
        switch self {
        case .save: return "save-icon"
        case .more: return "reports.more"
        }
    }
}
