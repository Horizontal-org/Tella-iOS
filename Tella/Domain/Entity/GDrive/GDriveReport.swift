//
//  GDriveReport.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class GDriveReport: BaseReport {
    
    var server: GDriveServer?
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
         server: GDriveServer? = nil,
         folderId: String? = nil,
         vaultFiles: [ReportFile]? = nil) {
        
        self.server = server
        self.folderId = folderId
        
        super.init(id: id,
                   title: title,
                   description: description,
                   createdDate: createdDate,
                   updatedDate: updatedDate,
                   status: status,
                   vaultFiles: vaultFiles)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.folderId = try container.decodeIfPresent(String.self, forKey: .folderId)
        try super.init(from: decoder)
    }
}

