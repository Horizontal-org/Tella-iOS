//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import UIKit
import Combine


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
    case finish(isAutoDelete:Bool, title:String?)
}

enum UploadType {
    case progress(fileId: String?,type: UploadReportType)
    case createReport
}

enum UploadReportType {
    case createReport
    case putReportFile
    case postReportFile
    case headReportFile
}

class UploadDecode<T,T1>  {
    var dto : T?
    var domain : T1?
    var error : APIError?
    var headers : [AnyHashable:Any]?

    init(dto: T?, domain: T1?, error: APIError?, headers: [AnyHashable:Any]?) {
        self.dto = dto
        self.domain = domain
        self.error = error
        self.headers = headers
    }
}

enum OperationType{
    case autoUpload
    case uploadReport
    case unsentReport
}


enum URLSessionTaskType {
    case dataTask
    case uploadTask
}
