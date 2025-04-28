//
//  UwaziEntityRelationshipItem.swift
//  Tella
//
//  Created by gus valbuena on 5/2/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct EntityRelationshipItem: Identifiable, Codable, Equatable {
    let id: String
    let label: String
    
    enum CodingKeys: String, CodingKey {
        case id = "value"
        case label
    }

}
