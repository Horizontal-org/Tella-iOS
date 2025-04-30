//
//  Resource.swift
//  Tella
//
//  Created by gus valbuena on 3/7/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
    var externalId: String?
    var title: String
    var fileName: String
    
    init(id: String, externalId: String? = nil, title: String, fileName: String ) {
        self.id = id
        self.externalId = externalId
        self.title = title
        self.fileName = fileName
    }
}
