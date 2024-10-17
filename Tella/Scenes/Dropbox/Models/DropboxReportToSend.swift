//
//  DropboxReportToSend.swift
//  Tella
//
//  Created by gus valbuena on 10/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class DropboxReportToSend {
    let folderId: String?
    var name: String
    let description: String
    let files: [DropboxFileInfo]
    var remoteReportStatus: RemoteReportStatus
    
    init(folderId: String?, name: String, description: String, files: [DropboxFileInfo], remoteReportStatus: RemoteReportStatus) {
        self.folderId = folderId
        self.name = name
        self.description = description
        self.files = files
        self.remoteReportStatus = remoteReportStatus
    }
}
