//
//  DropboxReport.swift
//  Tella
//
//  Created by gus valbuena on 9/17/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class DropboxReport: BaseReport {
    
    var server: DropboxServer?
    var folderId: String?
    var remoteReportStatus: RemoteReportStatus? = .unknown

    enum CodingKeys: String, CodingKey {
        case folderId = "c_folder_id"
        case remoteReportStatus = "c_remote_report_status"
    }
    
    init(id: Int? = nil,
         title: String? = nil,
         description: String? = nil,
         createdDate: Date? = nil,
         updatedDate: Date? = nil,
         status: ReportStatus,
         server: DropboxServer? = nil,
         folderId: String? = nil,
         vaultFiles: [DropboxReportFile]? = nil,
         remoteReportStatus: RemoteReportStatus = .unknown) {
        
        self.server = server
        self.folderId = folderId
        self.remoteReportStatus = remoteReportStatus

        super.init(id: id,
                   title: title,
                   description: description,
                   createdDate: createdDate,
                   updatedDate: updatedDate,
                   status: status,
                   vaultFiles: vaultFiles,
                   serverId: self.server?.id)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(folderId, forKey: .folderId)
        try container.encodeIfPresent(remoteReportStatus?.rawValue, forKey: .remoteReportStatus)

    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.folderId = try container.decodeIfPresent(String.self, forKey: .folderId)
        if let status = try container.decodeIfPresent(Int.self, forKey: .remoteReportStatus) {
            self.remoteReportStatus = RemoteReportStatus(rawValue: status) ?? RemoteReportStatus.unknown
        }
        try super.init(from: decoder)
    }
}
