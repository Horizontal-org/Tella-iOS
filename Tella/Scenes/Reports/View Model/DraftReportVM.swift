//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class DraftReportVM: DraftMainViewModel<TellaServer> {
    override init(mainAppModel : MainAppModel, reportId:Int? = nil) {
        super.init(mainAppModel: mainAppModel, reportId: reportId)
    }
    
    override func validateReport() {
        $server.combineLatest( $isValidTitle, $isValidDescription, $files)
            .sink(receiveValue: { server, isValidTitle, isValidDescription, files in
                self.reportIsValid = ((server != nil) && isValidTitle && isValidDescription) || ((server != nil) && isValidTitle && !files.isEmpty)
            }).store(in: &subscribers)
        
        $isValidTitle.combineLatest($isValidDescription, $files)
            .sink(receiveValue: { isValidTitle, isValidDescription, files in
                DispatchQueue.main.async {
                    self.reportIsDraft = isValidTitle
                }
            }).store(in: &subscribers)
    }
    
    override func getServers() {
        serverArray = mainAppModel.tellaData?.tellaServers.value ?? []
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
            self.objectWillChange.send()
        }
        DispatchQueue.main.async {
            self.isValidTitle =  self.title.textValidator()
            self.isValidDescription = self.description.textValidator()
            self.reportIsValid = ((self.server != nil) && self.isValidTitle && self.isValidDescription) || ((self.server != nil) && self.isValidTitle && !self.files.isEmpty)
            self.reportIsDraft = self.isValidTitle
            self.objectWillChange.send()
        }
    }

    override func saveReport() {
        
        let report = Report(id: reportId,
                            title: title,
                            description: description,
                            status: status,
                            server: server,
                            vaultFiles: self.files.compactMap{ ReportFile(fileId: $0.id,
                                                                          status: .notSubmitted,
                                                                          bytesSent: 0,
                                                                          createdDate: Date())},
                            apiID: apiID)
        
        dump(report)
        
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
