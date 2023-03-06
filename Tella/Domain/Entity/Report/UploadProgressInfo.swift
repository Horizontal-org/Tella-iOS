//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class UploadProgressInfo {
    //
    // MARK: - Variables And Properties
    //
    @Published var current : Int = 0
    var task: URLSessionUploadTask?
    var fileId: String?
    var url: URL
    var status : FileStatus = .unknown
    var isOnBackground: Bool = false

    init(fileId: String? = nil, url: URL, status: FileStatus, isOnBackground: Bool = false) {
        self.fileId = fileId
        self.url = url
        self.status = status
        self.isOnBackground = isOnBackground
    }
}
