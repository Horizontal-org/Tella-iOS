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
    let values: [EntityRelationshipItemDTO]
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case values
        case type
    }

    func toDomain() -> DomainModel? {
        let transformedValues = values.map { dto -> EntityRelationshipItem in
            EntityRelationshipItem(id: dto.id, label: dto.label)
        }
        return UwaziRelationshipList(id: id,
                                     name: name,
                                     values: transformedValues,
                                     type: type ?? ""
        )
    }
}

struct EntityRelationshipItemDTO: Identifiable, Codable {
    let id: String
    let label: String
    let value: [EntityRelationshipItemDTO]?
}
