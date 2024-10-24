//
//  DropboxFileInfo.swift
//  Tella
//
//  Created by gus valbuena on 10/7/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class DropboxFileInfo {
    let url: URL
    let fileName: String
    let fileId: String
    var offset: Int64
    var sessionId: String?
    let totalBytes: Int64
    
    init(url: URL, fileName: String, fileId: String, offset: Int64, sessionId: String? = nil, totalBytes: Int64) {
        self.url = url
        self.fileName = fileName
        self.fileId = fileId
        self.offset = offset
        self.sessionId = sessionId
        self.totalBytes = totalBytes
    }
}
