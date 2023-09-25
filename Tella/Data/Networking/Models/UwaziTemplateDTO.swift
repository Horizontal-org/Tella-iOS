//
//  UwaziTemplateResult.swift
//  Tella
//
//  Created by Robert Shrestha on 8/9/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


struct UwaziTemplateDTO: Codable {
    let rows: [UwaziTemplateRowDTO]
}

class UwaziTemplateRowDTO: Codable, DataModel {
    let id, name: String?
    var translatedName: String? = ""
    var properties: [PropertyDTO]
    var commonProperties: [CommonPropertyDTO]
    let version: Int?
    let rowDefault: Bool?
    let color, entityViewPage: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, properties, commonProperties
        case version = "__v"
        case rowDefault = "default"
        case color, entityViewPage, translatedName
    }
    func toDomain() -> DomainModel? {
        UwaziTemplateRow(id: id,
                         name: name,
                         translatedName: translatedName,
                         properties: properties.compactMap{$0.toDomain() as? Property},
                         commonProperties: commonProperties.compactMap{$0.toDomain() as? CommonProperty},
                         version: version,
                         rowDefault: rowDefault,
                         entityViewPage: entityViewPage)
    }
}

// MARK: - CommonProperty
class CommonPropertyDTO: Codable, DataModel {
    let id, label, name: String?
    let isCommonProperty: Bool?
    let type: String?
    var translatedLabel: String? = ""
    let prioritySorting, generatedID: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case label, name, isCommonProperty, type, prioritySorting, translatedLabel
        case generatedID = "generatedId"
    }
    func toDomain() -> DomainModel? {
        CommonProperty(id: id, label: label, name: name, isCommonProperty: isCommonProperty, type: type, translatedLabel: translatedLabel, prioritySorting: prioritySorting, generatedID: generatedID)
    }
}

// MARK: - Property
class PropertyDTO: Codable, DataModel {
    let content, id, label, type: String?
    let propertyRequired: Bool?
    let name: String?
    var translatedLabel : String? = ""
    let filter, showInCard: Bool?
    let relationType: String?
    var values : [SelectValue]?

    enum CodingKeys: String, CodingKey {
        case content
        case id = "_id"
        case label, type
        case propertyRequired = "required"
        case name, filter, showInCard, relationType, translatedLabel
    }
    func toDomain() -> DomainModel? {
        Property(content: content,
                 id: id,
                 label: label,
                 type: type,
                 propertyRequired: propertyRequired,
                 name: name,
                 translatedLabel: translatedLabel,
                 filter: filter,
                 showInCard: showInCard,
                 relationType: relationType,
                 values: values)
    }
}
