//
//  NextcloudDraftViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class NextcloudDraftViewModel: DraftMainViewModel {
    
    let nextcloudRepository: NextcloudRepositoryProtocol
    
    init(repository: NextcloudRepositoryProtocol,
         reportId reportID: Int?,
         reportsMainViewModel: ReportsMainViewModel) {
        self.nextcloudRepository = repository
        super.init(reportId: reportID, reportsMainViewModel: reportsMainViewModel)
        self.getServer()
        self.fillReportVM()
    }

    override func fillReportVM() {
        
        guard let reportId = self.reportId,
              let report = self.mainAppModel.tellaData?.getNextcloudReport(id: reportId)
        else { return }
        
        self.title = report.title ?? ""
        self.description = report.description ?? ""
        
        if let vaultFileResult = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report.reportFiles?.compactMap{ $0.fileId } ?? []) {
            addFilesViewModel.files = Set(vaultFileResult)
        }
        
        validateTitleAndDescription()
    }
    
    override func saveReport() {
        
        let reportFiles = addFilesViewModel.files.compactMap {NextcloudReportFile(fileId: $0.id,
                                                            status: .notSubmitted,
                                                            bytesSent: 0,
                                                            createdDate: Date(),
                                                            reportInstanceId: reportId)}
        
        let report = NextcloudReport(id: reportId,
                                     title: title,
                                     description: description,
                                     status: status ?? .unknown,
                                     server: self.server as? NextcloudServer,
                                     vaultFiles: reportFiles)
        
        reportId == nil ? addReport(report: report) : updateReport(report: report)
    }
        
    private func addReport(report: NextcloudReport) {
        let reportId = mainAppModel.tellaData?.addNextcloudReport(report: report)
        
        guard let reportId  else {
            self.failureSavingReport = true
            return
        }
        self.reportId = reportId
        self.successSavingReport = true
    }
    
    private func updateReport(report: NextcloudReport) {
        
        let updatedReportResult = mainAppModel.tellaData?.updateNextcloudReport(report: report)

        switch updatedReportResult {
        case .success:
            self.successSavingReport = true
        case.failure:
            self.failureSavingReport = true
        default:
            break
        }
    }
    
    private func getServer() {
        self.server = mainAppModel.tellaData?.getNextcloudServer().first
    }
    
}
