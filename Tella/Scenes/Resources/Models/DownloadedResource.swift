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
    let createdAt: String
    let server: Server?
    
    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case externalId = "c_external_id"
        case title = "c_title"
        case fileName = "c_filename"
        case size = "c_size"
        case createdAt = "c_created_date"
        
        // serverProps
        case serverId = "c_server_id"
        case server
        case name = "c_name"
        case url = "c_url"
        case username = "c_username"
        case password = "c_password"
        case accessToken = "c_access_token"

    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.externalId = try container.decode(String.self, forKey: .externalId)
        self.title = try container.decode(String.self, forKey: .title)
        self.fileName = try container.decode(String.self, forKey: .fileName)
        self.size = try container.decode(String.self, forKey: .size)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        
        let serverId = try container.decodeIfPresent(Int.self, forKey: .serverId)
        let name: String? = try container.decodeIfPresent(String.self, forKey: .name)
        let url: String? = try container.decodeIfPresent(String.self, forKey: .url)
        let username: String? = try container.decodeIfPresent(String.self, forKey: .username)
        let password: String? = try container.decodeIfPresent(String.self, forKey: .password)
        let accessToken: String? = try container.decodeIfPresent(String.self, forKey: .accessToken)
        
        self.server = Server(id: serverId, name: name, serverURL: url, username: username, password: password, accessToken: accessToken)
            
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(externalId, forKey: .externalId)
        try container.encode(title, forKey: .title)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(size, forKey: .size)
        try container.encode(createdAt, forKey: .createdAt)
        
        if let server = server {
            try container.encode(server.id, forKey: .serverId)
            try container.encode(server.name, forKey: .name)
            try container.encode(server.url, forKey: .url)
            try container.encode(server.username, forKey: .username)
            try container.encode(server.password, forKey: .password)
            try container.encode(server.accessToken, forKey: .accessToken)
        }
    }

}
