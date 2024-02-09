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
    
    init(
        id: String,
        title: String,
        fileName: String,
        serverName: String
    ) {
        self.id = id
        self.title = title
        self.fileName = fileName
        self.serverName = serverName
    }
    
    static func == (lhs: ResourceCardViewModel, rhs: ResourceCardViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
