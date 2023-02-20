//
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation

class ReportFile : Hashable {

    var id : Int?
    var fileId : String?
    var status : FileStatus?
    var totalBytesSent : Int?
    var createdDate : Date?
    var updatedDate : Date?

    init(id: Int? = nil,
         fileId: String? = nil,
         status: FileStatus? = nil,
         totalBytesSent: Int? = 0,
         createdDate: Date? = nil,
         updatedDate: Date? = Date()) {
        self.id = id
        self.fileId = fileId
        self.status = status
        self.totalBytesSent = totalBytesSent
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
 
