//
//  GDriveDraftViewModel.swift
//  Tella
//
//  Created by gus valbuena on 6/13/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class GDriveDraftViewModel: DraftMainViewModel<GDriveServer> {
    private let gDriveRepository: GDriveRepositoryProtocol
    
    init(mainAppModel: MainAppModel, repository: GDriveRepositoryProtocol, reportId reportID: Int?) {
        self.gDriveRepository = repository
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
        if let reportId = self.reportId, let report = self.mainAppModel.tellaData?.getDriveReport(id: reportId) {
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
    override func submitReport() {
        saveReportForSubmission()
    }
    
    override func saveReportForSubmission() {
        self.status = .submissionScheduled
        self.saveReport()
    }
    
    override func saveReport() {
        let gDriveReport = GDriveReport(
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
        
        reportId == nil ? addReport(report: gDriveReport) : updateReport(report: gDriveReport)
    }
    
    func addReport(report: GDriveReport) {
        let idResult = mainAppModel.tellaData?.addGDriveReport(report: report)
        
        switch idResult {
        case .success(let id ):
            dump(id)
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
        self.server = mainAppModel.tellaData?.gDriveServers.value.first
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
