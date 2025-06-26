//
//  GDriveDraftViewModel.swift
//  Tella
//
//  Created by gus valbuena on 6/13/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

class GDriveDraftViewModel: DraftMainViewModel {
    let gDriveRepository: GDriveRepositoryProtocol
    
    init(repository: GDriveRepositoryProtocol, reportId reportID: Int?, reportsMainViewModel: ReportsMainViewModel) {
        self.gDriveRepository = repository
        super.init(reportId: reportID, reportsMainViewModel: reportsMainViewModel)
        
        self.getServer()
        self.fillReportVM()
    }

    override func fillReportVM() {
        if let reportId = self.reportId, let report = self.mainAppModel.tellaData?.getDriveReport(id: reportId) {
            self.title = report.title ?? ""
            self.description = report.description ?? ""
            
            if let vaultFileResult = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report.reportFiles?.compactMap{ $0.fileId } ?? []) {
                addFilesViewModel.files = Set(vaultFileResult)
            }
        }
        
        validateTitleAndDescription()
    }
    
    override func saveReport() {
        let gDriveReport = GDriveReport(
            id: reportId,
            title: title,
            description: description,
            status: status ?? .unknown,
            server: server as? GDriveServer,
            folderId: nil,
            vaultFiles: addFilesViewModel.files.compactMap { ReportFile( fileId: $0.id,
                                                            status: .notSubmitted,
                                                            bytesSent: 0,
                                                            createdDate: Date(),
                                                            reportInstanceId: reportId)}
        )
        
        reportId == nil ? addReport(report: gDriveReport) : updateReport(report: gDriveReport)
    }
    
    func addReport(report: GDriveReport) {
        let idResult = mainAppModel.tellaData?.addGDriveReport(report: report)
        
        switch idResult {
        case .success(let id ):
            self.reportId = id
            self.successSavingReport = true
        default:
            self.failureSavingReport = true
        }
    }
    
    func updateReport(report: GDriveReport) {
        let updatedReportResult = self.mainAppModel.tellaData?.updateDriveReport(report: report)
        
        switch updatedReportResult {
        case .success:
            self.successSavingReport = true
        default:
            self.failureSavingReport = true
        }
    }
    private func getServer() {
        self.server = mainAppModel.tellaData?.getDriveServers().first
    }
}
