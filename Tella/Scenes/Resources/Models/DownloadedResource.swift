//
//  Resource.swift
//  Tella
//
//  Created by gus valbuena on 2/1/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct DownloadedResource: Codable, Identifiable {
    let id: String
    let externalId: String
    let title: String
    let fileName: String
    let size: String
    let serverId: Int?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case externalId = "c_external_id"
        case title = "c_title"
        case fileName = "c_filename"
        case size = "c_size"
        case serverId = "c_server_id"
        case createdAt = "c_created_date"
    }
    
    init(id: String, externalId: String, title: String, fileName: String, size: String, serverId: Int?, createdAt: String) {
        self.id = id
        self.externalId = externalId
        self.title = title
        self.fileName = fileName
        self.size = size
        self.serverId = serverId
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.externalId = try container.decode(String.self, forKey: .externalId)
        self.title = try container.decode(String.self, forKey: .title)
        self.fileName = try container.decode(String.self, forKey: .fileName)
        self.size = try container.decode(String.self, forKey: .size)
        self.serverId = try container.decodeIfPresent(Int.self, forKey: .serverId)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
    }
}
