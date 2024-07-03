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

    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case fileId = "c_vault_file_instance_id"
        case status = "c_status"
        case bytesSent = "c_bytes_Sent"
        case createdDate = "c_created_date"
        case updatedDate = "c_updated_date"
    }
    
    init(id: Int? = nil,
         fileId: String? = nil,
         status: FileStatus? = nil,
         bytesSent: Int? = 0,
         createdDate: Date? = nil,
         updatedDate: Date? = Date()) {
        self.id = id
        self.fileId = fileId
        self.status = status
        self.bytesSent = bytesSent
        self.createdDate = createdDate
        self.updatedDate = updatedDate
    }

    static func == (lhs: ReportFile, rhs: ReportFile) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}
 
