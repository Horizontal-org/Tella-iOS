//
//  DropboxReportToSend.swift
//  Tella
//
//  Created by gus valbuena on 10/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct DropboxReportToSend {
    let folderId: String?
    let name: String
    let description: String
    let files: [DropboxFileInfo]
    var remoteReportStatus: RemoteReportStatus
}
