//
//  FileUpload.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation


// MARK: - FileUploadRequest
struct FileUploadRequest: Codable {
    
    let sessionID, transmissionID, fileID, nonce: String?

    enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
        case transmissionID = "transmissionId"
        case fileID = "fileId"
        case nonce
    }

    /// Query string for `PUT /api/v1/upload` 
    var uploadURLQueryParameters: [String: String?] {
        [
            CodingKeys.sessionID.rawValue: sessionID,
            CodingKeys.transmissionID.rawValue: transmissionID,
            CodingKeys.fileID.rawValue: fileID,
            CodingKeys.nonce.rawValue: nonce
        ]
    }
}
