//
//  UwaziTemplateResult.swift
//  Tella
//
//  Created by Robert Shrestha on 8/9/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


struct UwaziTemplateResult: Codable {
    let rows: [UwaziTemplate]?
}

// MARK: - Row
struct UwaziTemplate: Codable {
    let id, name: String?
    let translatedName: String? = ""
    let properties: [Property]?
    let commonProperties: [CommonProperty]?
    let v: Int?
    let rowDefault: Bool?
    let color, entityViewPage: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, properties, commonProperties
        case v = "__v"
        case rowDefault = "default"
        case color, entityViewPage, translatedName
    }
}

// MARK: - CommonProperty
struct CommonProperty: Codable {
    let id, label, name: String?
    let isCommonProperty: Bool?
    let type: String?
    let translatedLabel: String? = ""
    let prioritySorting, generatedID: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case label, name, isCommonProperty, type, prioritySorting, translatedLabel
        case generatedID = "generatedId"
    }
}

// MARK: - Property
struct Property: Codable {
    let content, id, label, type: String?
    let propertyRequired: Bool?
    let name: String?
    var translatedLabel : String? = ""
    let filter, showInCard: Bool?
    let relationType: String?

    enum CodingKeys: String, CodingKey {
        case content
        case id = "_id"
        case label, type
        case propertyRequired = "required"
        case name, filter, showInCard, relationType, translatedLabel
    }
}
