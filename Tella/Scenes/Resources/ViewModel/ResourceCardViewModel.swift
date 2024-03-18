//
//  ResourceCardViewModel.swift
//  Tella
//
//  Created by gus valbuena on 2/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class ResourceCardViewModel : Hashable, Identifiable {
    var id: String
    var externalId: String?
    var title: String
    var serverName: String
    var type: ResourceCardType
    var action: () -> Void
    @Published var isLoading: Bool
    
    init(resource: Resource, serverName: String, type: ResourceCardType, action: @escaping () -> Void, isLoading: Bool = false) {
        self.id = resource.id
        self.externalId = resource.externalId
        self.title = resource.title
        self.serverName = serverName
        self.type = type
        self.action = action
        self.isLoading = isLoading
    }
    
    static func == (lhs: ResourceCardViewModel, rhs: ResourceCardViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
