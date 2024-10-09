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
    
    enum CodingKeys: String, CodingKey {
        case folderId = "c_folder_id"
    }
    
    init(id: Int? = nil,
         title: String? = nil,
         description: String? = nil,
         createdDate: Date? = nil,
         updatedDate: Date? = nil,
         status: ReportStatus,
         server: DropboxServer? = nil,
         folderId: String? = nil,
         vaultFiles: [DropboxReportFile]? = nil) {
        
        self.server = server
        self.folderId = folderId
        
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
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.folderId = try container.decodeIfPresent(String.self, forKey: .folderId)
        try super.init(from: decoder)
    }
}
