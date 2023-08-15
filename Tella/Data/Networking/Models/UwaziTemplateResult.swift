//
//  UwaziTemplateResult.swift
//  Tella
//
//  Created by Robert Shrestha on 8/9/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


struct UwaziTemplateResult: Codable {
    let rows: [UwaziTemplate]
}

// MARK: - Row
class UwaziTemplate: Codable {
    let id, name: String?
    var translatedName: String? = ""
    var properties: [Property]
    var commonProperties: [CommonProperty]
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
class CommonProperty: Codable {
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
}

// MARK: - Property
class Property: Codable {
    let content, id, label, type: String?
    let propertyRequired: Bool?
    let name: String?
    var translatedLabel : String? = ""
    let filter, showInCard: Bool?
    let relationType: String?
    var values : [SelectValue]? = nil

    enum CodingKeys: String, CodingKey {
        case content
        case id = "_id"
        case label, type
        case propertyRequired = "required"
        case name, filter, showInCard, relationType, translatedLabel
    }
}
class CollectedTemplate: Codable {
    var id: Int?
    var serverId: Int?
    var serverName: String?
    var username: String?
    var entityRow: UwaziTemplate?
    var isDownloaded: Bool?
    var isFavorite: Bool?
    var isUpdated: Bool?

    init(id: Int? = nil,
         serverId: Int?,
         serverName: String? = nil,
         username: String? = nil,
         entityRow: UwaziTemplate,
         isDownloaded: Bool? = nil,
         isFavorite: Bool? = nil,
         isUpdated: Bool? = nil) {

        self.id = id
        self.serverId = serverId
        self.serverName = serverName
        self.username = username
        self.entityRow = entityRow
        self.isDownloaded = isDownloaded
        self.isFavorite = isFavorite
        self.isUpdated = isUpdated
    }

    enum CodingKeys: String, CodingKey {
        case id = "c_template_id"
        case serverId = "c_server_id"
        case serverName
        case username
        case entityRow = "c_template_entity"
        case isDownloaded = "c_template_downloaded"
        case isFavorite = "c_template_favorited"
        case isUpdated = "c_template_updated"
    }

    var entityRowString: String? {
        do {
            if let jsonData = try? JSONEncoder().encode(entityRow), let json = String(bytes: jsonData, encoding: .utf8) {
                // Here you have your array as a json string
                // So you can save it into a string column

                print(json) // ["one","two","three"]
                return json
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
