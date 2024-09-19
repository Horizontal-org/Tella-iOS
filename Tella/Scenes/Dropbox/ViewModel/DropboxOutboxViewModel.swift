//
//  DropboxOutboxViewModel.swift
//  Tella
//
//  Created by gus valbuena on 9/19/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class DropboxOutboxViewModel: OutboxMainViewModel<DropboxServer> {
    let dropboxRepository: DropboxRepositoryProtocol
    
    override var shouldShowCancelUploadConfirmation: Bool {
        return true
    }
    
    init(reportsViewModel: ReportsMainViewModel,
                  reportId: Int?,
                  repository: DropboxRepositoryProtocol) {
        self.dropboxRepository = repository
        super.init(reportsViewModel: reportsViewModel, reportId: reportId)

        if reportViewModel.status == .submissionScheduled {
            self.submitReport()
        }
    }
    
    override func initVaultFile(reportId: Int?) {
        if let reportId, let report = self.mainAppModel.tellaData?.getDropboxReport(id: reportId) {
            let files = processVaultFiles(reportFiles: report.reportFiles)
            
            self.reportViewModel = ReportViewModel(report: report, files: files)
        }
    }
}
