//
//  Resource.swift
//  Tella
//
//  Created by gus valbuena on 2/1/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct Resource: Codable, Identifiable {
    let id: String
    let title: String
    let fileName: String
    let size: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, fileName, size, createdAt
    }
}

struct DownloadedResource: Codable, Identifiable {
    let id: Int?
    let externalId: String
    let vaultFileId: String
    let title: String
    let fileName: String
    let size: String
    let serverId: Int?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, externalId, vaultFileId, title, fileName, size, serverId, createdAt
    }
}
