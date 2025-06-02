//
//  FileUpload.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/3/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation


// MARK: - FileUploadRequest
struct FileUploadRequest: Codable {
    let sessionID, transmissionID, fileID: String?
    let data: Data?

    enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
        case transmissionID = "transmissionId"
        case fileID = "fileId"
        case data
    }
}



