//
//  ResourceCardViewModel.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class ResourceCardViewModel: Hashable, Identifiable {
    var id: String
    var title: String
    var fileName: String
    var serverName: String
    var size: String
    var createdAt: String
    
    init(
        id: String,
        title: String,
        fileName: String,
        serverName: String,
        size: String,
        createdAt: String
    ) {
        self.id = id
        self.title = title
        self.fileName = fileName
        self.serverName = serverName
        self.size = size
        self.createdAt = createdAt
    }
    
    static func == (lhs: ResourceCardViewModel, rhs: ResourceCardViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class DownloadedResourceCardViewModel: Hashable, Identifiable {
    var id: Int
    var externalId: String
    var vaultFileId: String
    var title: String
    var fileName: String
    var serverName: String
    var size: String
    var createdAt: String
    
    init(
        id: Int,
        externalId: String,
        vaultFileId: String,
        title: String,
        fileName: String,
        serverName: String,
        size: String,
        createdAt: String
    ) {
        self.id = id
        self.externalId = externalId
        self.vaultFileId = vaultFileId
        self.title = title
        self.fileName = fileName
        self.serverName = serverName
        self.size = size
        self.createdAt = createdAt
    }
    
    static func == (lhs: DownloadedResourceCardViewModel, rhs: DownloadedResourceCardViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
