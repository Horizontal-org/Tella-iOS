//
//  UwaziLanguageResult.swift
//  Tella
//
//  Created by Robert Shrestha on 5/25/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct UwaziLanguageDTO: Codable, DataModel {
    let rows: [UwaziLanguageRowDTO]?
    func toDomain() -> DomainModel? {
        let rows = rows?.compactMap{ $0.toDomain() as? UwaziLanguageRow}
        return UwaziLanguage(rows: rows)
    }
}

// MARK: - Row
struct UwaziLanguageRowDTO: Codable, DataModel {

    let id: String?
    let locale: String?
    let contexts: [UwaziLanguageContextDTO]?

    func toDomain() -> DomainModel? {
        var languageName = "English"
        let currentLocale: Locale = .current
        if let locale = self.locale {
            languageName = currentLocale.localizedString(forLanguageCode: "\(locale)_\(locale.uppercased())") ?? "English"
        }
        return UwaziLanguageRow(id: id, locale: locale, languageName: languageName)
    }
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case locale, contexts
    }
}

//// MARK: - Context
struct UwaziLanguageContextDTO: Codable, DataModel {
    let contextID, label: String?
    let type: UwaziLanguageTypeEnum?
    let values: [String: String]?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case contextID = "id"
        case label
        case type, values
        case id = "_id"
    }
    func toDomain() -> DomainModel? {
        return UwaziLanguageContext(contextID: contextID, label: label, id: id)
    }
}

enum UwaziLanguageTypeEnum: String, Codable {
    case entity = "Entity"
    case relationshipType = "Relationship Type"
    case thesaurus = "Thesaurus"
    case uwaziUI = "Uwazi UI"
}
