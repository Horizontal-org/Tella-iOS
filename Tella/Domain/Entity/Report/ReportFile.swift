//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class ReportFile : Hashable, Codable {
    
    var id : Int?
    var fileId : String?
    var status : FileStatus?
    var bytesSent : Int?
    var createdDate : Date?
    var updatedDate : Date?
    var reportInstanceId : Int?
    var chunkFiles: [(fileName: String, size: Int64)]?

    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case fileId = "c_vault_file_instance_id"
        case status = "c_status"
        case bytesSent = "c_bytes_Sent"
        case createdDate = "c_created_date"
        case updatedDate = "c_updated_date"
        case reportInstanceId = "c_report_instance_id"
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
        self.id = id
        self.fileId = fileId
        self.status = status
        self.bytesSent = bytesSent
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.reportInstanceId = reportInstanceId
        self.chunkFiles = chunkFiles
    }
    
    init(file: ReportVaultFile, reportInstanceId: Int?) {
        self.id = file.instanceId
        self.fileId = file.id
        self.status = file.status
        self.bytesSent = file.bytesSent
        self.createdDate = file.createdDate
        self.updatedDate = file.updatedDate
        self.reportInstanceId = reportInstanceId
        self.chunkFiles = file.chunkFiles
    }
    
    static func == (lhs: ReportFile, rhs: ReportFile) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fileId, forKey: .fileId)
        try container.encode(status, forKey: .status)
        try container.encode(bytesSent, forKey: .bytesSent)
        let createdDate = createdDate?.getDateDouble()
        try container.encode(createdDate, forKey: .createdDate)
        let updatedDate = Date().getDateDouble()
        try container.encode(updatedDate, forKey: .updatedDate)
        try container.encode(reportInstanceId, forKey: .reportInstanceId)
        
        let structArray = chunkFiles?.compactMap { ChunkFile(fileName: $0.fileName, size: $0.size) }
        try container.encodeIfPresent(structArray.jsonString, forKey: .chunkFiles)

    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        
        self.fileId = try container.decode(String.self, forKey: .fileId)
        
        let status = try container.decode(Int.self, forKey: .status)
        self.status = FileStatus(rawValue: status) ?? FileStatus.unknown
        
        self.bytesSent = try container.decode(Int.self, forKey: .bytesSent)
        let createdDate = try container.decode(Double.self, forKey: .createdDate)
        self.createdDate = createdDate.getDate()
        
        let updatedDate = try container.decode(Double.self, forKey: .updatedDate)
        self.updatedDate = updatedDate.getDate()
        
        self.reportInstanceId = try container.decode(Int.self, forKey: .reportInstanceId)
        
        if let chunkFilesJsonString = try container.decodeIfPresent(String.self, forKey: .chunkFiles) {
            let decodedStructArray = chunkFilesJsonString.decodeJSON([ChunkFile].self)
            // Convert array of structs back to array of named tuples
            let decodedFilesArray = decodedStructArray?.compactMap { (fileName: $0.fileName, size: $0.size) }
            self.chunkFiles = decodedFilesArray
        }

    }
}


struct ChunkFile: Codable {
    let fileName: String
    let size: Int64
}
