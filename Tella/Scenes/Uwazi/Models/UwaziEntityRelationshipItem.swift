//
//  UwaziEntityRelationshipItem.swift
//  Tella
//
//  Created by gus valbuena on 5/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct EntityRelationshipItem: Identifiable, Codable {
    let id: String
    let label: String
    
    enum CodingKeys: String, CodingKey {
        case id = "value"
        case label
    }

}
