//
//  EntityCreationResponse.swift
//  Tella
//
//  Created by Gustavo on 23/10/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

enum EntityResult {
    case publicEntity(Entity)
    case authorizedEntity(EntityCreationResponse)
}

struct EntityCreationResponse: Decodable {
    let entity: Entity?
    let errors: [UwaziError]?
}


struct Entity: Decodable {
    let id: String?
    let language: String?
    let sharedId: String?
    let title: String?
    let template: String?
    let published: Bool?
    let creationDate: Int64?
    let editDate: Int64?
    let metadata: [String: [MetaDataItem]]?
    let user: String?
    let permissions: [Permission]?
    let __v: Int?
    let documents: [Attachment]?
    let attachments: [Attachment]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case language
        case sharedId
        case title
        case template
        case published
        case creationDate
        case editDate
        case metadata
        case user
        case permissions
        case __v
        case documents
        case attachments
    }
}

struct MetaDataItem: Decodable {
    let value: MetaDataType?
    let label: String?

    enum MetaDataType {
        case stringValue(String)
        case intValue(Int)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let intValue = try? container.decode(Int.self, forKey: .value) {
            self.value = .intValue(intValue)
        } else if let stringValue = try? container.decode(String.self, forKey: .value) {
            self.value = .stringValue(stringValue)
        } else {
            throw DecodingError.typeMismatch(
                MetaDataType.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected value to be either Int or String"
                )
            )
        }
        label = try container.decodeIfPresent(String.self, forKey: .label)
    }

    private enum CodingKeys: String, CodingKey {
        case value, label
    }
}

struct Permission: Decodable {
    let refId: String
    let type: String
    let level: String
}

struct Attachment: Decodable {
    let id: String?
    let entity: String?
    let type: String?
    let filename: String?
    let originalname: String?
    let mimetype: String?
    let size: Int64?
    let creationDate: Int64?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case entity
        case type
        case filename
        case originalname
        case mimetype
        case size
        case creationDate
    }
}

struct UwaziError: Codable {
    let error: String?
    let prettyMessage: String?
}


