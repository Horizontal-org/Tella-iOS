//
//  UwaziRelationshipDTO.swift
//  Tella
//
//  Created by gus valbuena on 4/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct UwaziRelationshipDTO: Codable {
    let rows: [UwaziRelationshipRowDTO]
}

struct UwaziRelationshipRowDTO: Codable, DataModel {
    let id, name: String
    let values: [EntityRelationshipItem]
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case values
        case type
    }

    func toDomain() -> DomainModel? {
        UwaziRelationshipList(id: id, name: name, values: values, type: type ?? "")
    }
}

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

