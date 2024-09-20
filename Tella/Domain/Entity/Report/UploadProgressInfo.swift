//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class UploadProgressInfo {
    
    //
    // MARK: - Variables And Properties
    //
    
    var bytesSent : Int?
    var current : Int?
    var fileId: String?
    var status : FileStatus = .unknown
    var isOnBackground: Bool = false
    var error: APIError?
    var reportStatus: ReportStatus?
    
    init(fileId: String? = nil, status: FileStatus) {
        self.fileId = fileId
        self.status = status
    }
    
    init(bytesSent: Int? = nil,
         current : Int? = nil,
         fileId: String? = nil,
         status: FileStatus,
         error: APIError? = nil,
         reportStatus: ReportStatus? = nil) {
        
        self.bytesSent = bytesSent
        self.fileId = fileId
        self.status = status
        self.status = status
        self.reportStatus = reportStatus
        self.current = current
    }
}
