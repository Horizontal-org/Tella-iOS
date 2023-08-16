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
    var templateId: String?
    var serverId: Int?
    var serverName: String?
    var username: String?
    var entityRow: UwaziTemplate?
    var isDownloaded: Int?
    var isFavorite: Int?
    var isUpdated: Int?

    init(id: Int? = nil,
         serverId: Int?,
         templateId: String?,
         serverName: String? = nil,
         username: String? = nil,
         entityRow: UwaziTemplate,
         isDownloaded: Int? = nil,
         isFavorite: Int? = nil,
         isUpdated: Int? = nil) {

        self.id = id
        self.templateId = templateId
        self.serverId = serverId
        self.serverName = serverName
        self.username = username
        self.entityRow = entityRow
        self.isDownloaded = isDownloaded
        self.isFavorite = isFavorite
        self.isUpdated = isUpdated
    }

    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case templateId = "c_template_id"
        case serverId = "c_server_id"
        case serverName = "c_server_name"
        case username
        case entityRow = "c_template_entity"
        case isDownloaded = "c_template_downloaded"
        case isFavorite = "c_template_favorited"
        case isUpdated = "c_template_updated"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(Int.self, forKey: .id)
        templateId = try container.decodeIfPresent(String.self, forKey: .templateId)
        serverId = try container.decodeIfPresent(Int.self, forKey: .serverId)
        serverName = try container.decodeIfPresent(String.self, forKey: .serverName)
        username = try container.decodeIfPresent(String.self, forKey: .username)

        // Decode entityRow as a string
        if let entityRowString = try container.decodeIfPresent(String.self, forKey: .entityRow) {
            if let jsonData = entityRowString.data(using: .utf8), let array = try? JSONDecoder().decode(UwaziTemplate.self, from: jsonData) {
                entityRow = array
            } else {
                throw DecodingError.dataCorruptedError(forKey: .entityRow, in: container, debugDescription: "entityRow issue")
            }
        }
        isDownloaded = try container.decodeIfPresent(Int.self, forKey: .isDownloaded)
        isFavorite = try container.decodeIfPresent(Int.self, forKey: .isFavorite)
        isUpdated = try container.decodeIfPresent(Int.self, forKey: .isUpdated)
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
