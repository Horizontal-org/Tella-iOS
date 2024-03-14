//
//  Resource.swift
//  Tella
//
//  Created by gus valbuena on 2/1/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct DownloadedResource: Codable, Identifiable {
    let id: String
    let externalId: String
    let title: String
    let fileName: String
    let size: String
    let createdAt: String
    var server: Server?
    
    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case externalId = "c_external_id"
        case title = "c_title"
        case fileName = "c_filename"
        case size = "c_size"
        case createdAt = "c_created_date"
        case server
    }
}
