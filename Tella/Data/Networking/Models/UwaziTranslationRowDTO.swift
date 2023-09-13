//
//  UwaziTranslationResult.swift
//  Tella
//
//  Created by Robert Shrestha on 8/9/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

struct UwaziTranslationDTO: Codable, DataModel {
    let rows: [UwaziTranslationRowDTO]?
    func toDomain() -> DomainModel? {
        UwaziTranslation(rows: rows?.compactMap{$0.toDomain() as? UwaziTranslationRow})
    }
}

struct UwaziTranslationRowDTO: Codable, DataModel {
    let id, locale: String?
    let contexts: [UwaziTranslationContextDTO]
    let version: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case locale, contexts
        case version = "__v"
    }
    func toDomain() -> DomainModel? {
        UwaziTranslationRow(id: id,
                            locale: locale,
                            contexts: contexts.compactMap{$0.toDomain() as? UwaziTranslationContext})
    }
}

// MARK: - Context
struct UwaziTranslationContextDTO: Codable, DataModel {
    let contextID, label: String?
    let type: String?
    let values: [String: String]?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case contextID = "id"
        case label, type, values
        case id = "_id"
    }
    func toDomain() -> DomainModel? {
        UwaziTranslationContext(
            contextID: contextID,
                           values: values,
                           id: id)
    }

}
