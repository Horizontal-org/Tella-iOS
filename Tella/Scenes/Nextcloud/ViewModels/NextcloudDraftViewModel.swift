//
//  NextcloudDraftViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class NextcloudDraftViewModel: DraftMainViewModel<NextcloudServer> {
    
    private let nextcloudRepository: NextcloudRepositoryProtocol
    
    init(mainAppModel: MainAppModel, repository: NextcloudRepositoryProtocol, reportId reportID: Int?) {
        self.nextcloudRepository = repository
        super.init(mainAppModel: mainAppModel, reportId: reportID)
        
        self.getServer()
        
        self.reportId = reportID
        self.fillReportVM()
    }
    
    override func validateReport() {
        Publishers.CombineLatest($title, $description)
            .map { !$0.0.isEmpty && !$0.1.isEmpty }
            .assign(to: \.reportIsValid, on: self)
            .store(in: &subscribers)
        
        $title
            .map { !$0.isEmpty }
            .assign(to: \.reportIsDraft, on: self)
            .store(in: &subscribers)
    }
    
    override func fillReportVM() {
        if let reportId = self.reportId,
           let report = self.mainAppModel.tellaData?.getNextcloudReport(id: reportId) {
            
            self.title = report.title ?? ""
            self.description = report.description ?? ""
            
            if let vaultFileResult = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report.reportFiles?.compactMap{ $0.fileId } ?? []) {
                self.files = Set(vaultFileResult)
            }
            
            self.objectWillChange.send()
        }
    }
    
    override func saveDraftReport() {
        self.status = .draft
        self.saveReport()
    }
    
    override func saveFinalizedReport() {
        self.status = .finalized
        self.saveReport()
    }
    
    func saveSubmittedReport() {
        self.status = .submitted
        self.saveReport()
    }
    
    override func saveReport() {
        
        let report = NextcloudReport(
            id: reportId,
            title: title,
            description: description,
            status: status ?? .unknown,
            server: server,
            vaultFiles: self.files.compactMap { ReportFile( fileId: $0.id,
                                                            status: .notSubmitted,
                                                            bytesSent: 0,
                                                            createdDate: Date())}
        )
        
        reportId == nil ? addReport(report: report) : updateReport(report: report)
    }
    
    func addReport(report: NextcloudReport) {
        let reportId = mainAppModel.tellaData?.addNextcloudReport(report: report)
        
        guard let reportId  else {
            self.failureSavingReport = true
            return
        }
        self.reportId = reportId
        self.successSavingReport = true
    }
    
    func updateReport(report: NextcloudReport) {
        
        let updatedReportResult = mainAppModel.tellaData?.updateNextcloudReport(report: report)
        
        guard let updatedReportResult, updatedReportResult else {
            self.failureSavingReport = true
            return
        }
        self.successSavingReport = true
        
    }
    
    private func getServer() {
        self.server = mainAppModel.tellaData?.nextcloudServers.value.first
    }
    
    override func deleteFile(fileId: String?) {
        guard let index = files.firstIndex(where: { $0.id == fileId})  else  {return }
        files.remove(at: index)
    }
    
    override func bindVaultFileTaken() {
        $resultFile.sink(receiveValue: { value in
            guard let value else { return }
            self.files.insert(value)
        }).store(in: &subscribers)
    }
}
