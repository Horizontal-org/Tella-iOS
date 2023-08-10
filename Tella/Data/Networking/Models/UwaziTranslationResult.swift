//
//  UwaziTranslationResult.swift
//  Tella
//
//  Created by Robert Shrestha on 8/9/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

struct UwaziTranslationResult: Codable {
    let rows: [UwaziTranslation]?
}

// MARK: - Row
struct UwaziTranslation: Codable {
    let id, locale: String?
    let contexts: [TranslationContext]?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case locale, contexts
        case v = "__v"
    }
}

// MARK: - Context
struct TranslationContext: Codable {
    let contextID, label: String?
    let type: String?
    let values: [String: String]?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case contextID = "id"
        case label, type, values
        case id = "_id"
    }
}
