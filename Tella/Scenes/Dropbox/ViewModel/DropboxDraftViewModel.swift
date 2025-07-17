//
//  DropboxDraftViewModel.swift
//  Tella
//
//  Created by gus valbuena on 9/12/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

class DropboxDraftViewModel: DraftMainViewModel {
    let dropboxRepository: DropboxRepositoryProtocol
    
    init(DropboxRepository: DropboxRepositoryProtocol, reportId: Int?, reportsMainViewModel: ReportsMainViewModel) {
        self.dropboxRepository = DropboxRepository
        super.init(reportId: reportId, reportsMainViewModel: reportsMainViewModel)
        
        self.getServer()
        self.fillReportVM()
    }

    override func fillReportVM() {
        
        guard let reportId = self.reportId,
              let report = self.mainAppModel.tellaData?.getDropboxReport(id: reportId)
        else { return }
        
        self.title = report.title ?? ""
        self.description = report.description ?? ""
        
        if let vaultFileResult = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report.reportFiles?.compactMap{ $0.fileId } ?? []) {
            addFilesViewModel.files = Set(vaultFileResult)
        }
        
        validateTitleAndDescription()
    }
    
    override func saveReport() {
        let dropboxReport = DropboxReport(
            id: reportId,
            title: title,
            description: description,
            status: status ?? .unknown,
            server: server as? DropboxServer,
            vaultFiles: addFilesViewModel.files.compactMap { DropboxReportFile( fileId: $0.id,
                                                                   status: .notSubmitted,
                                                                   bytesSent: 0,
                                                                   createdDate: Date(),
                                                                   reportInstanceId: reportId)}
        )
        
        reportId == nil ? addReport(report: dropboxReport) : updateReport(report: dropboxReport)
    }
    
    func addReport(report: DropboxReport) {
        let idResult = mainAppModel.tellaData?.addDropboxReport(report: report)
        
        switch idResult {
        case .success(let id ):
            self.reportId = id
            self.successSavingReport = true
        default:
            self.failureSavingReport = true
        }
    }
    
    func updateReport(report: DropboxReport) {
        let updatedReportResult = self.mainAppModel.tellaData?.updateDropboxReport(report: report)
        
        switch updatedReportResult {
        case .success:
            self.successSavingReport = true
        default:
            self.failureSavingReport = true
        }
    }
    
    private func getServer() {
        self.server = mainAppModel.tellaData?.getDropboxServers().first
    }
}
