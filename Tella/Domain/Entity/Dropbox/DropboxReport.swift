//
//  DropboxReport.swift
//  Tella
//
//  Created by gus valbuena on 9/17/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class DropboxReport: BaseReport {
    
    var server: DropboxServer?
    var remoteReportStatus: RemoteReportStatus? = .initial

    enum CodingKeys: String, CodingKey {
        case remoteReportStatus = "c_remote_report_status"
    }
    
    init(id: Int? = nil,
         title: String? = nil,
         description: String? = nil,
         createdDate: Date? = nil,
         updatedDate: Date? = nil,
         status: ReportStatus,
         server: DropboxServer? = nil,
         vaultFiles: [DropboxReportFile]? = nil,
         remoteReportStatus: RemoteReportStatus = .initial) {
        
        self.server = server
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
        try container.encodeIfPresent(remoteReportStatus?.rawValue, forKey: .remoteReportStatus)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let status = try container.decodeIfPresent(Int.self, forKey: .remoteReportStatus) {
            self.remoteReportStatus = RemoteReportStatus(rawValue: status) ?? RemoteReportStatus.initial
        }
        try super.init(from: decoder)
    }
}
