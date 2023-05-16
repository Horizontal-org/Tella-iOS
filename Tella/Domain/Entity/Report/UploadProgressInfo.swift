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
    @Published var current : Int?
     var total : Int?

    var task: URLSessionUploadTask?
    var fileId: String?
    var status : FileStatus = .unknown
    var isOnBackground: Bool = false
    var error: APIError?
    var reportStatus: ReportStatus?

    init(fileId: String? = nil, status: FileStatus) {
        self.fileId = fileId
        self.status = status
    }
    
    init(bytesSent: Int? = nil,current : Int? = nil, fileId: String? = nil, status: FileStatus, error: APIError? = nil, total: Int? = nil, reportStatus: ReportStatus? = nil) {
        self.bytesSent = bytesSent
        self.current = current
        self.fileId = fileId
         self.status = status
        self.status = status
        self.total = total
        self.reportStatus = reportStatus

     }

}
