//
//  ReportFileExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 31/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension ReportFile {
    
    convenience init?(reportVaultFile: ReportVaultFile) {
        self.init(id:reportVaultFile.instanceId,
                  fileId: reportVaultFile.id,
                  status: reportVaultFile.status,
                  bytesSent: reportVaultFile.bytesSent,
                  createdDate: reportVaultFile.createdDate,
                  updatedDate: reportVaultFile.updatedDate,
                  reportInstanceId: reportVaultFile.reportInstanceId)
    }
}

extension NextcloudReportFile {
    
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

extension DropboxReportFile {
    
    convenience init?(reportFile: ReportVaultFile) {
        self.init(id:reportFile.instanceId,
                  fileId: reportFile.id,
                  status: reportFile.status,
                  bytesSent: reportFile.bytesSent,
                  createdDate: reportFile.createdDate,
                  updatedDate: reportFile.updatedDate,
                  reportInstanceId: reportFile.reportInstanceId,
                  sessionId: reportFile.sessionId)
    }
}
