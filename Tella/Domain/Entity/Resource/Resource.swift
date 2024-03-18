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

class Resource: DomainModel, Codable {
    var id: String
    var externalId: String?
    var title: String
    var fileName: String
    var server: Server?
    
    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case externalId = "c_external_id"
        case title = "c_title"
        case fileName = "c_filename"
        case server
    }
    
    init(id: String, externalId: String? = nil, title: String, fileName: String, server: Server? = nil ) {
        self.id = id
        self.externalId = externalId
        self.title = title
        self.fileName = fileName
        self.server = server
    }
}
