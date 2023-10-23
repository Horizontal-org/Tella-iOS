//
//  EntityCreationResponse.swift
//  Tella
//
//  Created by Gustavo on 23/10/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

struct EntityCreationResponse: Codable {
    let id: String
    let title: String
    let template: String
    let language: String
    let published: Bool
    let creationDate: Int
    let editDate: Int
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case template
        case language
        case published
        case creationDate
        case editDate
    }
}
