//
//  ReportFileExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 31/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension ReportFile {
    
    convenience init?(reportFile: ReportVaultFile) {
        self.init(id:reportFile.instanceId,
                  fileId: reportFile.id,
                  status: reportFile.status,
                  bytesSent: reportFile.bytesSent,
                  createdDate: reportFile.createdDate,
                  updatedDate: reportFile.updatedDate,
                  reportInstanceId: reportFile.reportInstanceId,
                  chunkFiles: reportFile.chunkFiles)
    }
    
}
