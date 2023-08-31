//
//  UwaziLanguageResult.swift
//  Tella
//
//  Created by Robert Shrestha on 5/25/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation


// MARK: - Welcome
struct UwaziLanguageResult: Codable {
    let rows: [UwaziLanguageRow]?
}
// MARK: - Row
struct UwaziLanguageRow: Codable, Hashable {

    let id: String?
    let locale: String?
    let contexts: [UwaziLanguageContext]?
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case locale, contexts
    }
    static func == (lhs: UwaziLanguageRow, rhs: UwaziLanguageRow) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(locale)
    }

    func languageName() -> String {
        let currentLocale: Locale = .current
        guard let locale = self.locale else { return "English"}
        return currentLocale.localizedString(forLanguageCode: "\(locale)_\(locale.uppercased())") ?? "English"
    }
}

// MARK: - Context
struct UwaziLanguageContext: Codable {
    let contextID, label: String?
    let type: UwaziLanguageTypeEnum?
    let values: [String: String]?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case contextID = "id"
        case label, type, values
        case id = "_id"
    }
}

enum UwaziLanguageTypeEnum: String, Codable {
    case entity = "Entity"
    case relationshipType = "Relationship Type"
    case thesaurus = "Thesaurus"
    case uwaziUI = "Uwazi UI"
}
