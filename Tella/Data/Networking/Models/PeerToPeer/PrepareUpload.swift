//
//  PrepareUploadRequest.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/3/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation

// MARK: - PrepareUploadRequest
struct PrepareUploadRequest: Codable {
    let title, sessionID: String?
    let metadata: Metadata?

    enum CodingKeys: String, CodingKey {
        case title
        case sessionID = "sessionId"
        case metadata
    }
}

// MARK: - Metadata
struct Metadata: Codable {
    let files: P2PFile?
}

// MARK: - Files
struct P2PFile: Codable {
    let fileID: FileID?

    enum CodingKeys: String, CodingKey {
        case fileID = "fileId"
    }
}

// MARK: - FileID
struct FileID: Codable {
    let id, fileName: String?
    let size: Int?
    let fileType, sha256: String?
}


// MARK: - PrepareUploadResponse
struct PrepareUploadResponse: Codable {
    let transmissionID: String

    enum CodingKeys: String, CodingKey {
        case transmissionID = "transmissionId"
    }
}

