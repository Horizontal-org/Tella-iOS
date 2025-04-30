//
//  UwaziRelationshipList.swift
//  Tella
//
//  Created by gus valbuena on 5/14/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class UwaziRelationshipList: DomainModel, Codable, Identifiable {
    let id, name: String
    let values: [EntityRelationshipItem]
    let type: String

    init(id: String, name: String, values: [EntityRelationshipItem], type: String) {
        self.id = id
        self.name = name
        self.values = values
        self.type = type
    }
}
