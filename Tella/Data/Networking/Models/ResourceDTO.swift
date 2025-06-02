//
//  ResourceDTO.swift
//  Tella
//
//  Created by gus valbuena on 2/7/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct ProjectDTO: DataModel, Codable {
    let id: String
    let name: String
    let slug: String
    let url: String
    let resources: [ResourceDTO]
    let createdAt: String
    
    func toDomain() -> DomainModel? {
        let resources = resources.compactMap { $0.toDomain() as? Resource}
        
        return Project(
            id: id,
            resources: resources
        )
    }
}

struct ResourceDTO: Codable, Identifiable, DataModel {
    let id: String
    let title: String
    let fileName: String
    let size: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, fileName, size, createdAt
    }
    
    func toDomain() -> DomainModel? {
        return Resource(
            id: id,
            title: title,
            fileName: fileName
        )
    }
}
