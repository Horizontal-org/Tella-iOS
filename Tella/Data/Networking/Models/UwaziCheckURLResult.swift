//
//  UwaziCheckURLResult.swift
//  Tella
//
//  Created by Robert Shrestha on 5/22/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

struct UwaziCheckURLResult: Codable {
    let id: String
    let siteName: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case siteName = "site_name"
    }
}
