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
    let values: [ThesauriValue]
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


struct ThesauriValue: Codable {
    let label: String
    let id: String
    let values: [ThesauriValue]?
}


class UwaziRelationshipList: DomainModel, Codable {
    let id, name: String
    let values: [ThesauriValue]
    let type: String

    init(id: String, name: String, values: [ThesauriValue], type: String) {
        self.id = id
        self.name = name
        self.values = values
        self.type = type
    }
}

