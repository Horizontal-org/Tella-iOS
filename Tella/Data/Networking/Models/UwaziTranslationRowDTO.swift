//
//  UwaziTranslationResult.swift
//  Tella
//
//  Created by Robert Shrestha on 8/9/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct UwaziTranslationDTO: Codable {
    let rows: [UwaziTranslationRowDTO]?
}

struct UwaziTranslationRowDTO: Codable {
    let id, locale: String?
    let contexts: [UwaziTranslationContextDTO]?
    let version: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case locale, contexts
        case version = "__v"
    }
}

// MARK: - Context
struct UwaziTranslationContextDTO: Codable {
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
