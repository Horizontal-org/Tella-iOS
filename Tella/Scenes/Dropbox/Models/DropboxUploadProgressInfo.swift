//
//  DropboxUploadProgressInfo.swift
//  Tella
//
//  Created by gus valbuena on 10/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

enum DropboxUploadResponse {
    case initial
    case progress(progressInfo: DropboxUploadProgressInfo)
    case folderCreated(folderName: String)
    case descriptionSent
}

class DropboxUploadProgressInfo: UploadProgressInfo {
    var sessionId: String?

    override init(fileId: String? = nil, status: FileStatus) {
        super.init(fileId: fileId, status: status)
    }

    init(bytesSent: Int?,
         current: Int,
         fileId: String,
         status: FileStatus,
         reportStatus: ReportStatus,
         sessionId: String?) {
        self.sessionId = sessionId
        super.init(bytesSent: bytesSent, current: current, fileId: fileId, status: status, reportStatus: reportStatus)
    }
}
