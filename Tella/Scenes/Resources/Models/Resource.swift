//
//  Resource.swift
//  Tella
//
//  Created by gus valbuena on 2/1/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct Resource: Codable, Identifiable {
    let id: String
    let title: String
    let fileName: String
    let size: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, fileName, size, createdAt
    }
}

struct DownloadedResource: Codable, Identifiable {
    let id: Int?
    let externalId: String
    let title: String
    let fileName: String
    let size: String
    let serverId: Int?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, externalId, title, fileName, size, serverId, createdAt
    }
}


// Mock data --- to be removed after API implementation
let ListOfAvailableResources = [
    Resource(
        id: "d9be243e-af3e-4b0f-b4bf-bfa9bdd76069",
        title: "Digital security tips",
        fileName: "Digital_security_tips.pdf",
        size: "49338",
        createdAt: "2024-01-22T15:35:38.000Z"
    ),
    Resource(
        id: "d9be243e-af3e-4b0f-b4bf-bfa9bdd76170",
        title: "What to do if ...",
        fileName: "what_to_do.pdf",
        size: "49338",
        createdAt: "2024-01-22T15:35:38.000Z"
    ),
    Resource(
        id: "d9be243e-af3e-4b0f-b4bf-bfa9bdd76073",
        title: "Important contact info",
        fileName: "important_contact_info",
        size: "49338",
        createdAt: "2024-01-22T15:35:38.000Z"
    ),
    Resource(
        id: "d9be243e-af3e-4b0f-b4bf-bfa9bdd76075",
        title: "Important contact info",
        fileName: "important_contact_info",
        size: "49338",
        createdAt: "2024-01-22T15:35:38.000Z"
    ),
    Resource(
        id: "d9be243e-af3e-4b0f-b4bf-bfa9bdd76076",
        title: "Important contact info",
        fileName: "important_contact_info",
        size: "49338",
        createdAt: "2024-01-22T15:35:38.000Z"
    )
]

let ListOfDownloadedResources = [
    Resource(
        id: "d9be243e-af3e-4b0f-b4bf-bfa9bdd76073",
        title: "Intro: Start here",
        fileName: "intro.pdf",
        size: "49338",
        createdAt: "2024-01-22T15:35:38.000Z"
    ),
    Resource(
        id: "d9be243e-af3e-4b0f-b4bf-bfa9bdd76074",
        title: "How to submit a report",
        fileName: "how_to_submit.pdf",
        size: "49338",
        createdAt: "2024-01-22T15:35:38.000Z"
    ),
]
