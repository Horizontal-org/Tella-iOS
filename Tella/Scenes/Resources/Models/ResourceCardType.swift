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
    
    var imageName: ImageResource {
        switch self {
        case .save: return .saveIcon
        case .more: return .reportsMore
        }
    }
}
