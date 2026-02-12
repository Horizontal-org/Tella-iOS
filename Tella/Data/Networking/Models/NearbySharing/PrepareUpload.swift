//
//  PrepareUploadRequest.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

// MARK: - PrepareUpload
struct PrepareUploadRequest: Codable {
    let title, sessionID: String?
    let files: [NearbySharingFile]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case sessionID = "sessionId"
        case files
    }
}

// MARK: - NearbySharingFile
class NearbySharingFile: Codable {
    var id, fileName: String?
    var size: Int?
    var fileType, sha256: String?
    var thumbnail: Data?
    init(id: String?,
         fileName: String?,
         size: Int?,
         fileType: String?,
         thumbnail: Data?) {
        self.id = id
        self.fileName = fileName
        self.size = size
        self.fileType = fileType
        self.thumbnail = thumbnail
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.fileName, forKey: .fileName)
        try container.encodeIfPresent(self.size, forKey: .size)
        try container.encodeIfPresent(self.fileType, forKey: .fileType)
        try container.encodeIfPresent(self.thumbnail?.base64EncodedString(), forKey: .thumbnail)
    }
}

extension NearbySharingFile {
    convenience init(vaultFile: VaultFileDB) {
        self.init(id: vaultFile.id,
                  fileName: vaultFile.name,
                  size: vaultFile.size,
                  fileType: vaultFile.mimeType,
                  thumbnail: vaultFile.thumbnail)
    }
}

// MARK: - PrepareUploadResponse
struct PrepareUploadResponse: Codable {
    var files: [NearbySharingFileResponse]?
    
}

struct NearbySharingFileResponse: Codable {
    let id: String?
    let transmissionID: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case transmissionID = "transmissionId"
    }
}
