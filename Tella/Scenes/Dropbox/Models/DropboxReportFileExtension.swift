//
//  DropboxReportFileExtension.swift
//  Tella
//
//  Created by gus valbuena on 9/26/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

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
