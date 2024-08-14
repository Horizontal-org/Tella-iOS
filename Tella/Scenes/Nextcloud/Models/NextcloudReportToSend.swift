//
//  NextcloudReportToSend.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 31/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct NextcloudReportToSend {
    var folderName : String
    var descriptionFileUrl : URL?
    var remoteReportStatus : RemoteReportStatus
    var files : [NextcloudMetadata]
    var server : NextcloudServerParameters
}


enum RemoteReportStatus : Int, Codable {
    case unknown = 0
    case initial = 1
    case created = 2
    case descriptionSent = 3
}


