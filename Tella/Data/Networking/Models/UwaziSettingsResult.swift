//
//  UwaziSettingsResult.swift
//  Tella
//
//  Created by Robert Shrestha on 8/9/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct UwaziSettingResult: Codable {
    let id, siteName: String?
    let languages: [UwaziLanguageRow]?
    let v: Int?
    let isPrivate: Bool?
    let allowedPublicTemplates: [String]?
    let mapAPIKey: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case siteName = "site_name"
        case languages
        case v = "__v"
        case isPrivate = "private"
        case allowedPublicTemplates
        case mapAPIKey = "mapApiKey"
    }
}
