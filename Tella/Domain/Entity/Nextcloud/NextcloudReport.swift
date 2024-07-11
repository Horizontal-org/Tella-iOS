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
    
    init(id: Int? = nil,
         title: String? = nil,
         description: String? = nil,
         createdDate: Date? = nil,
         updatedDate: Date? = nil,
         status: ReportStatus,
         server: NextcloudServer? = nil,
         vaultFiles: [ReportFile]? = nil) {
        
        self.server = server
        
        super.init(id: id,
                   title: title,
                   description: description,
                   createdDate: createdDate,
                   updatedDate: updatedDate,
                   status: status,
                   vaultFiles: vaultFiles)
    }
    
    required init(from decoder: any Decoder) throws {
        try super.init(from: decoder)
    }
}

