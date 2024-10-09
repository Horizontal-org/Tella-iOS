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
    case folderCreated(folderId: String, folderName: String)
    case finished
}

class DropboxUploadProgressInfo: UploadProgressInfo {
    var sessionId: String?

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

class FileUploadState {
    let fileURL: URL
    let fileName: String
    let fileId: String
    var sessionId: String?
    var offset: Int64
    let totalBytes: Int64
    
    init(fileURL: URL, fileName: String, fileId: String, sessionId: String?, offset: Int64, totalBytes: Int64) {
        self.fileURL = fileURL
        self.fileName = fileName
        self.fileId = fileId
        self.sessionId = sessionId
        self.offset = offset
        self.totalBytes = totalBytes
    }
}