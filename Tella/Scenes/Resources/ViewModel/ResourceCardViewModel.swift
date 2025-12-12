//
//  ResourceCardViewModel.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class ResourceCardViewModel : Hashable, Identifiable {
    var id: String?
    var externalId: String?
    var title: String
    var serverName: String
    var type: ResourceCardType
    var action: () -> Void
    var onTap: () -> Void?
    var isLoading: Bool
    private let identity: String
    
    init(resource: Resource,
         serverName: String,
         type: ResourceCardType,
         action: @escaping () -> Void,
         isLoading: Bool = false
    ) {
        self.id = resource.id
        self.identity = resource.id ?? UUID().uuidString
        self.externalId = resource.externalId
        self.title = resource.title ?? ""
        self.serverName = serverName
        self.type = type
        self.action = action
        self.isLoading = isLoading
        self.onTap = {}
    }
    
    init(resource: DownloadedResource,
         type: ResourceCardType,
         action: @escaping () -> Void,
         onTap: @escaping () -> Void,
         isLoading: Bool = false ) {
        
        self.id = resource.id
        self.identity = resource.id ?? UUID().uuidString
        self.externalId = resource.externalId
        self.title = resource.title
        self.serverName = resource.server?.name ?? ""
        self.type = type
        self.action = action
        self.onTap = onTap
        self.isLoading = isLoading
    }
    
    static func == (lhs: ResourceCardViewModel, rhs: ResourceCardViewModel) -> Bool {
        lhs.identity == rhs.identity
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }
}
