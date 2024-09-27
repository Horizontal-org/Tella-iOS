//
//  DropboxReportFile.swift
//  Tella
//
//  Created by gus valbuena on 9/26/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class DropboxReportFile: ReportFile {
    var offset: Int64?
    var sessionId: String?
    
    enum CodingKeys: String, CodingKey {
        case offset = "c_offset"
        case sessionId = "c_session_id"
    }
    
    init(id: Int? = nil,
         fileId: String? = nil,
         status: FileStatus? = nil,
         bytesSent: Int? = 0,
         createdDate: Date? = nil,
         updatedDate: Date? = Date(),
         reportInstanceId: Int? = nil,
         offset: Int64? = nil,
         sessionId: String? = nil
    ) {
        super.init(id: id,
                   fileId: fileId,
                   status: status,
                   bytesSent: bytesSent,
                   createdDate: createdDate,
                   updatedDate: updatedDate,
                   reportInstanceId: reportInstanceId)
        
        self.offset = offset
        self.sessionId = sessionId

    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.offset = try container.decodeIfPresent(Int64.self, forKey: .offset)
        self.sessionId = try container.decodeIfPresent(String.self, forKey: .sessionId)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(offset, forKey: .offset)
        try container.encodeIfPresent(sessionId, forKey: .sessionId)
        
        try super.encode(to: encoder)
    }
}
