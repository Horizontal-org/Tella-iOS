//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine
import SwiftUI

class DraftReportVM: DraftMainViewModel {
    
    override init(reportId:Int? = nil, reportsMainViewModel: ReportsMainViewModel) {
        super.init(reportId: reportId, reportsMainViewModel: reportsMainViewModel)
    }

    override func getServers() {
        serverArray = mainAppModel.tellaData?.getTellaServers() ?? []
    }
    
    override func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    override func fillReportVM() {
        if let reportId = self.reportId ,let report = self.mainAppModel.tellaData?.getReport(reportId: reportId) {
            
            self.title = report.title ?? ""
            self.description = report.description ?? ""
            self.server = report.server
            
            if let  vaultFileResult = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report.reportFiles?.compactMap{$0.fileId} ?? [] ) {
                let vaultFileResult  = Set(vaultFileResult)
                addFilesViewModel.files = vaultFileResult
            }
        }
        
        validateTitleAndDescription()
    }

    override func saveReport() {
        
        let report = Report(id: reportId,
                            title: title,
                            description: description,
                            status: status,
                            server: server as? TellaServer,
                            vaultFiles: addFilesViewModel.files.compactMap{ ReportFile(fileId: $0.id,
                                                                          status: .notSubmitted,
                                                                          bytesSent: 0,
                                                                          createdDate: Date())},
                            apiID: apiID)
        
        !isNewDraft ? updateReport(report: report) : addReport(report: report)
    }
    
    private func updateReport(report:Report) {
        let updateReportResult = mainAppModel.tellaData?.updateReport(report: report)
        switch updateReportResult {
        case .success:
            self.successSavingReport = true
        default:
            self.failureSavingReport = true
        }
    }
    
    private func addReport(report:Report) {
        let idResult =  mainAppModel.tellaData?.addReport(report: report)
        switch idResult {
        case .success(let id ):
            self.reportId = id
            self.successSavingReport = true
        default:
            self.failureSavingReport = true
        }
    }
    
    override func deleteReport() {
        mainAppModel.deleteReport(reportId: reportId)
        mainAppModel.deleteReport(reportId: reportId)
    }
}
