//
//  UwaziTemplateResults.swift
//  Tella
//
//  Created by Gustavo on 01/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

struct UwaziTemplateResult: Codable {
    let rows: [UwaziTemplateRow]?
}

struct UwaziTemplateRow: Codable, Hashable {
    let id, name: String?
    let properties: [UwaziTemplateProperty]?
    let commonProperties: [UwaziTemplateProperty]?
    let v: Int?
    let defaultVal: Bool?
    let color: String?
    
    enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name, properties, commonProperties
            case v = "__v"
            case defaultVal = "default"
            case color
        }
}

struct UwaziTemplateProperty: Codable, Hashable {
    let content, id, label, type: String?
    let required: Bool?
    let name, relationType: String?
    let showInCard: Bool?
    let generatedId: Bool?

    enum CodingKeys: String, CodingKey {
        case content, id, label, type, required, name, relationType, showInCard
        case generatedId
    }
}

enum UwaziTemplatePropertyType: String, Codable {
    case date = "date"
    case geolocation = "geolocation"
    case image = "image"
    case numeric = "numeric"
    case relationship = "relationship"
    case select = "select"
    case text = "text"
}
