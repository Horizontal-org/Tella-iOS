//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class UploadProgressInfo {
    //
    // MARK: - Variables And Properties
    //
    var isDownloading = false
    @Published var size : Int = 0
    @Published var current : Int = 0
    
    var task: URLSessionUploadTask?
    var fileId: String?
    var url: URL
    var status : FileStatus = .unknown
    
    init(fileId: String? = nil, url: URL, status: FileStatus) {
        self.fileId = fileId
        self.url = url
        self.status = status
    }
}

 
