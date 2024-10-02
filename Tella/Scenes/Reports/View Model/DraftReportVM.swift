//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
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
    
    override func bindVaultFileTaken() {
        $resultFile.sink(receiveValue: { value in
            guard let value else { return }
            self.files.insert(value)
            self.publishUpdates()
        }).store(in: &subscribers)
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
                self.files = vaultFileResult
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
                            vaultFiles: self.files.compactMap{ ReportFile(fileId: $0.id,
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
    
    override func deleteFile(fileId: String?) {
        guard let index = files.firstIndex(where: { $0.id == fileId})  else  {return }
        files.remove(at: index)
    }
    
    override func deleteReport() {
        mainAppModel.deleteReport(reportId: reportId)
        mainAppModel.deleteReport(reportId: reportId)
    }
}
