//
//  ResourceCardViewModel.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class ResourceCardViewModel : Identifiable {
    var title: String
    var serverName: String
    var type: ResourceCardType
    var action: () -> Void
    
    init(title: String, serverName: String, type: ResourceCardType, action: @escaping () -> Void) {
        self.title = title
        self.serverName = serverName
        self.type = type
        self.action = action
    }
}

class AvailableResourcesList: Hashable, Identifiable {
    var id: String
    var resourceCard: ResourceCardViewModel
    var fileName: String
    var size: String
    var createdAt: String
    var isLoading: Bool
    
    init(
        id: String,
        resourceCard: ResourceCardViewModel,
        fileName: String,
        size: String,
        createdAt: String,
        isLoading: Bool = false
    ) {
        self.id = id
        self.resourceCard = resourceCard
        self.fileName = fileName
        self.size = size
        self.createdAt = createdAt
        self.isLoading = isLoading
    }
    
    static func == (lhs: AvailableResourcesList, rhs: AvailableResourcesList) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class DownloadedResourcesList: Hashable, Identifiable {
    var id: String
    var externalId: String
    var resourceCard: ResourceCardViewModel
    var fileName: String
    var size: String
    var createdAt: String
    
    init(
        id: String,
        externalId: String,
        resourceCard: ResourceCardViewModel,
        fileName: String,
        size: String,
        createdAt: String
    ) {
        self.id = id
        self.externalId = externalId
        self.resourceCard = resourceCard
        self.fileName = fileName
        self.size = size
        self.createdAt = createdAt
    }
    
    static func == (lhs: DownloadedResourcesList, rhs: DownloadedResourcesList) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
