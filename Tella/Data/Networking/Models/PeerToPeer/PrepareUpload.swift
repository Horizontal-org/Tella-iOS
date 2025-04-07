//
//  PrepareUploadRequest.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/3/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation

// MARK: - PrepareUpload
struct PrepareUploadRequest: Codable {
    let title, sessionID: String
    let files: [P2PFile]
    
    enum CodingKeys: String, CodingKey {
        case title
        case sessionID = "sessionId"
        case files
    }
}

// MARK: - P2PFile
struct P2PFile: Codable {
    let id, fileName: String
    let size: Int
    let fileType, sha256: String
}

// MARK: - PrepareUploadResponse
struct PrepareUploadResponse: Codable {
    let transmissionID: String
    
    enum CodingKeys: String, CodingKey {
        case transmissionID = "transmissionId"
    }
}
