//
//  NextcloudReportToSend.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 31/7/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct NextcloudReportToSend {
    var folderName: String
    var descriptionFileUrl: URL?
    var remoteReportStatus: RemoteReportStatus
    var files: [NextcloudMetadata]
    var server: NextcloudServerModel
}

enum RemoteReportStatus : Int, Codable {
    case initial = 1
    case created = 2
    case descriptionSent = 3
}


