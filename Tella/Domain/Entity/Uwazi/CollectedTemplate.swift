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
    var relationships: [UwaziRelationshipList]?
    var isDownloaded: Bool?
    var isFavorite: Bool?
    var isUpdated: Bool?

    init(id: Int? = nil,
         serverId: Int?,
         templateId: String?,
         serverName: String? = nil,
         username: String? = nil,
         entityRow: UwaziTemplateRow,
         relationships: [UwaziRelationshipList]? = nil,
         isDownloaded: Bool? = nil,
         isFavorite: Bool? = nil,
         isUpdated: Bool? = nil) {

        self.id = id
        self.templateId = templateId
        self.serverId = serverId
        self.serverName = serverName
        self.username = username
        self.relationships = relationships
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
        case entityRow = "c_entity"
        case relationships = "c_relationships"
        case isDownloaded = "c_downloaded"
        case isFavorite = "c_favorite"
        case isUpdated = "c_updated"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(templateId, forKey: .templateId)
        try container.encode(serverId, forKey: .serverId)
        try container.encode(entityRow?.jsonString, forKey: .entityRow)
        try container.encode(relationships?.jsonString, forKey: .relationships)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(Int.self, forKey: .id)
        templateId = try container.decodeIfPresent(String.self, forKey: .templateId)
        serverId = try container.decodeIfPresent(Int.self, forKey: .serverId)
        serverName = try container.decodeIfPresent(String.self, forKey: .serverName)
        username = try container.decodeIfPresent(String.self, forKey: .username)

        if let entityRowString = try container.decodeIfPresent(String.self, forKey: .entityRow) {
            entityRow = try entityRowString.decodeJSON(UwaziTemplateRow.self)
        }
        
        if let relationshipsString = try container.decodeIfPresent(String.self, forKey: .relationships) {
            relationships = try relationshipsString.decodeJSON([UwaziRelationshipList].self)
        }
        isDownloaded = try container.decodeIfPresent(Int.self, forKey: .isDownloaded) == 1 ? true : false
        isFavorite = try container.decodeIfPresent(Int.self, forKey: .isFavorite) == 1 ? true : false
        isUpdated = try container.decodeIfPresent(Int.self, forKey: .isUpdated) == 1 ? true : false
    }
    
    static func == (lhs: CollectedTemplate, rhs: CollectedTemplate) -> Bool {
        return (lhs.id == rhs.id) && (lhs.templateId == rhs.templateId)
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(templateId)
    }
}
