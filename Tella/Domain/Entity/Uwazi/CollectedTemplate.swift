//
//  CollectedTemplate.swift
//  Tella
//
//  Created by Robert Shrestha on 9/8/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
// Made Codable to Parse this object to and from Database so not using DTO pattern here
class CollectedTemplate: Codable, Hashable {
    var id: Int?
    var templateId: String?
    var serverId: Int?
    var serverName: String?
    var username: String?
    var entityRow: UwaziTemplateRow?
    var isDownloaded: Bool?
    var isFavorite: Bool?
    var isUpdated: Bool?

    init(id: Int? = nil,
         serverId: Int?,
         templateId: String?,
         serverName: String? = nil,
         username: String? = nil,
         entityRow: UwaziTemplateRow,
         isDownloaded: Bool? = nil,
         isFavorite: Bool? = nil,
         isUpdated: Bool? = nil) {

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

    static func == (lhs: CollectedTemplate, rhs: CollectedTemplate) -> Bool {
        return (lhs.id == rhs.id) && (lhs.templateId == rhs.templateId)
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
            if let jsonData = entityRowString.data(using: .utf8), let array = try? JSONDecoder().decode(UwaziTemplateRow.self, from: jsonData) {
                entityRow = array
            } else {
                throw DecodingError.dataCorruptedError(forKey: .entityRow, in: container, debugDescription: "entityRow issue")
            }
        }
        isDownloaded = try container.decodeIfPresent(Int.self, forKey: .isDownloaded) == 1 ? true : false
        isFavorite = try container.decodeIfPresent(Int.self, forKey: .isFavorite) == 1 ? true : false
        isUpdated = try container.decodeIfPresent(Int.self, forKey: .isUpdated) == 1 ? true : false
    }
    // TODO: Ask if this also need to be changed
    var entityRowString: String? {
        if let jsonData = try? JSONEncoder().encode(entityRow), let json = String(bytes: jsonData, encoding: .utf8) {
            return json
        } else {
            return nil
        }
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(templateId)
    }
}
