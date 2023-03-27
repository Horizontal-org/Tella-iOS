//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import UIKit
import Combine

typealias Output = (data: Data?, response: URLResponse)

//enum UploadResponse {
//    case initial(isOnBackground:Bool)
//    case progress(progressInfo: UploadProgressInfo)
//    case response(response: Output?)
//}

//enum APIResponse<Value> {
//    case initial
//    case response(response: Value?)
//    case progress(progressInfo: UploadProgressInfo)
//}

class UploadTask {
    var task: URLSessionTask
    var response: UploadType
    
    init(task: URLSessionTask, response: UploadType) {
        self.task = task
        self.response = response
    }
}

enum UploadResponse {
    case initial
    case progress(progressInfo: UploadProgressInfo)
    case createReport(apiId: String?, reportStatus:ReportStatus?, error:APIError?)
}

enum UploadType {
    case progress(fileId: String,type: UploadReportType)
    case createReport
}

enum UploadReportType {
    case createReport
    case putReportFile
    case postReportFile
    case headReportFile
}
