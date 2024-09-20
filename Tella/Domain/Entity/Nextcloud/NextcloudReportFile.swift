//
//  NextcloudReportFile.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/8/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class NextcloudReportFile : ReportFile {
    
    var chunkFiles: [(fileName: String, size: Int64)]?
    
    enum CodingKeys: String, CodingKey {
        case chunkFiles = "c_chunk_files"
    }
    
    init(id: Int? = nil,
         fileId: String? = nil,
         status: FileStatus? = nil,
         bytesSent: Int? = 0,
         createdDate: Date? = nil,
         updatedDate: Date? = Date(),
         reportInstanceId: Int? = nil,
         chunkFiles: [(fileName: String, size: Int64)]? = nil) {
        
        super.init(id: id,
                   fileId: fileId,
                   status: status,
                   bytesSent: bytesSent,
                   createdDate: createdDate,
                   updatedDate: updatedDate,
                   reportInstanceId: reportInstanceId)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let chunkFilesJsonString = try container.decodeIfPresent(String.self, forKey: .chunkFiles) {
            let decodedStructArray = chunkFilesJsonString.decodeJSON([ChunkFile].self)
            // Convert array of structs back to array of named tuples
            let decodedFilesArray = decodedStructArray?.compactMap { (fileName: $0.fileName, size: $0.size) }
            self.chunkFiles = decodedFilesArray
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Convert array of named tuples to array of structs
        let structArray = chunkFiles?.compactMap { ChunkFile(fileName: $0.fileName, size: $0.size) }
        try container.encodeIfPresent(structArray.jsonString, forKey: .chunkFiles)
        try super.encode(to: encoder)
    }
    
}

struct ChunkFile: Codable {
    let fileName: String
    let size: Int64
}
