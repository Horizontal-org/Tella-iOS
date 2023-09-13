//
//  UwaziTemplateRow.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
// TODO: Removed unwanted variables when done with entity flow no removed now due to confusion on what will be need in future implementation
// We save this object in the database so it is confronting to Codable
class UwaziTemplateRow: DomainModel, Codable {
    let id, name: String?
    var translatedName: String? = ""
    var properties: [Property]
    var commonProperties: [CommonProperty]
    let version: Int?
    let rowDefault: Bool?
    let entityViewPage: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, properties, commonProperties
        case version = "__v"
        case rowDefault = "default"
        case entityViewPage, translatedName
    }
    init(id: String?, name: String?, translatedName: String?, properties: [Property], commonProperties: [CommonProperty], version: Int?, rowDefault: Bool?, entityViewPage: String?) {
        self.id = id
        self.name = name
        self.translatedName = translatedName
        self.properties = properties
        self.commonProperties = commonProperties
        self.version = version
        self.rowDefault = rowDefault
        self.entityViewPage = entityViewPage
    }
}
