//
//  GDriveData.swift
//  Tella
//
//  Created by gus valbuena on 6/28/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension TellaData {
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
    
    func getDriveReport(id: Int) -> GDriveReport? {
        self.database.getGDriveReport(id: id)
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
    func updateDriveReportStatus(idReport: Int, status: ReportStatus) -> Result<Bool, Error> {
        shouldReloadGDriveReports.send(true)
        
        return self.database.updateDriveReportStatus(idReport: idReport, status: status)
    }
    
    @discardableResult
    func updateDriveFolderId(idReport: Int, folderId: String) -> Result<Bool, Error> {
        shouldReloadGDriveReports.send(true)
        
        return self.database.updateDriveReportFolderId(idReport: idReport, folderId: folderId)
    }
}
