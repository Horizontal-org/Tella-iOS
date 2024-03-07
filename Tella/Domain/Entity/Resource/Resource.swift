//
//  Resource.swift
//  Tella
//
//  Created by gus valbuena on 3/7/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class Project: DomainModel {
    var id: String
    var resources: [Resource]
    
    init(id: String, resources: [Resource]) {
        self.id = id
        self.resources = resources
    }
}

class Resource: DomainModel {
    var id: String
    var title: String
    var fileName: String
    var size: String
    var createdAt: String
    
    init(id: String, title: String, fileName: String, size: String, createdAt: String) {
        self.id = id
        self.title = title
        self.fileName = fileName
        self.size = size
        self.createdAt = createdAt
    }
}
