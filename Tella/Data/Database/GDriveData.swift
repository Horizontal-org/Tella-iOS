//
//  GDriveData.swift
//  Tella
//
//  Created by gus valbuena on 6/28/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension TellaData {
    
    func getDriveServers() -> [GDriveServer] {
        self.database.getDriveServers()
    }

    func addGDriveReport(report : GDriveReport) -> Result<Int, Error> {
        let id =  database.addGDriveReport(report: report)
        
        shouldReloadGDriveReports.send(true)
        
        return id
    }
    
    func getDraftGDriveReport() -> [GDriveReport] {
        return self.database.getDriveReports(reportStatus: [ReportStatus.draft])
    }
    
    func getOutboxedGDriveReport() -> [GDriveReport] {
        return self.database.getDriveReports(reportStatus: [.finalized,
                                                            .submissionError,
                                                            .submissionPending,
                                                            .submissionPaused,
                                                            .submissionInProgress,
                                                            .submissionAutoPaused,
                                                            .submissionScheduled])
    }
    
    func getSubmittedGDriveReport() -> [GDriveReport] {
        return self.database.getDriveReports(reportStatus: [ReportStatus.submitted])
    }
    
    func getDriveReport(id: Int?) -> GDriveReport? {
        guard let id else { return nil }
        return self.database.getGDriveReport(id: id)
    }
    
    func updateDriveReport(report: GDriveReport) -> Result<Bool, Error> {
        shouldReloadGDriveReports.send(true)
        return self.database.updateDriveReport(report: report)
    }
    
    func deleteDriveReport(reportId: Int?) -> Result<Bool, Error> {
        shouldReloadGDriveReports.send(true)
        return self.database.deleteDriveReport(reportId: reportId)
    }
    
    @discardableResult
    func updateDriveReportStatus(reportId: Int, status: ReportStatus) -> Result<Bool, Error> {
        shouldReloadGDriveReports.send(true)
        
        return self.database.updateDriveReportStatus(idReport: reportId, status: status)
    }
    
    @discardableResult
    func updateDriveFolderId(reportId: Int, folderId: String) -> Result<Bool, Error> {
        shouldReloadGDriveReports.send(true)
        
        return self.database.updateDriveReportFolderId(idReport: reportId, folderId: folderId)
    }
    
    @discardableResult
    func updateDriveFiles(reportId: Int, files: [ReportFile]) -> Result<Bool, Error> {
        shouldReloadGDriveReports.send(true)
        
        return self.database.updateDriveReportFiles(files: files, reportId: reportId)
    }
}
