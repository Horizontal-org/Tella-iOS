//
//  UwaziSubmitEntityResponse.swift
//  Tella
//
//  Created by Gustavo on 20/09/2023.
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
    // Add other properties as needed to match the response structure

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case template
        case language
        case published
        case creationDate
        case editDate
        // Add other coding keys for additional properties
    }
}
