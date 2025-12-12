//
//  UwaziCheckURLResult.swift
//  Tella
//
//  Created by Robert Shrestha on 5/22/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct UwaziCheckURLDTO: Codable, DataModel {
    let id: String?
    let siteName: String?
    let isPrivate: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case siteName = "site_name"
        case isPrivate = "private"
    }
    func toDomain() -> DomainModel? {
        UwaziCheckURL(id: id, siteName: siteName, isPrivate: isPrivate)
    }
}
