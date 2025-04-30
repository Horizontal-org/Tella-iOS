//
//  DownloadedResource.swift
//  Tella
//
//  Created by gus valbuena on 3/19/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct DownloadedResource: Codable, Identifiable {
    let id: String
    let externalId: String
    let title: String
    let fileName: String
    var server: Server?

    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case externalId = "c_external_id"
        case title = "c_title"
        case fileName = "c_filename"
    }
}
