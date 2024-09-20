//
//  NextcloudReport.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class NextcloudReport: BaseReport {
    
    var server: NextcloudServer?
    var remoteReportStatus: RemoteReportStatus? = .unknown
    
    enum CodingKeys: String, CodingKey {
        case remoteReportStatus = "c_remote_report_status"
    }
    
    init(id: Int? = nil,
         title: String? = nil,
         description: String? = nil,
         createdDate: Date? = nil,
         updatedDate: Date? = nil,
         status: ReportStatus,
         server: NextcloudServer? = nil,
         vaultFiles: [NextcloudReportFile]? = nil,
         remoteReportStatus: RemoteReportStatus = .unknown) {
        
        super.init(id: id,
                   title: title,
                   description: description,
                   createdDate: createdDate,
                   updatedDate: updatedDate,
                   status: status,
                   serverId: self.server?.id)
        
        self.server = server
        self.remoteReportStatus = remoteReportStatus
        self.reportFiles = vaultFiles
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(remoteReportStatus?.rawValue, forKey: .remoteReportStatus)
        try super.encode(to: encoder)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let status = try container.decodeIfPresent(Int.self, forKey: .remoteReportStatus) {
            self.remoteReportStatus = RemoteReportStatus(rawValue: status) ?? RemoteReportStatus.unknown
        }
        try super.init(from: decoder)
    }
}

