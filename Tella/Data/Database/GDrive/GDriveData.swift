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
        database.addGDriveReport(report: report)
    }
    
    func getDraftGDriveReport() -> [GDriveReport] {
        return self.database.getDriveReports(reportStatus: [ReportStatus.draft])
    }
    
    func getOutboxedGDriveReport() -> [GDriveReport] {
        return self.database.getOutboxReports(tableName: D.tGDriveReport)
    }
    
    func getSubmittedGDriveReport() -> [GDriveReport] {
        return self.database.getDriveReports(reportStatus: [ReportStatus.submitted])
    }
    
    func getDriveReport(id: Int?) -> GDriveReport? {
        guard let id else { return nil }
        return self.database.getGDriveReport(id: id)
    }
    
    func updateDriveReport(report: GDriveReport) -> Result<Void, Error> {
        self.database.updateDriveReport(report: report)
    }
    
    func deleteDriveReport(reportId: Int?) -> Result<Void, Error> {
        let deleteDriveReportResult = self.database.deleteDriveReport(reportId: reportId)
        shouldReloadGDriveReports.send(true)
        return deleteDriveReportResult
    }
    
    @discardableResult
    func deleteDriveSubmittedReports() -> Result<Void,Error> {
        let deleteSubmittedReportResult = database.deleteDriveSubmittedReports()
        shouldReloadNextcloudReports.send(true)
        return deleteSubmittedReportResult
    }

    
    @discardableResult
    func updateDriveReportStatus(reportId: Int, status: ReportStatus) -> Result<Void, Error> {
        self.database.updateDriveReportStatus(idReport: reportId, status: status)
    }
    
    @discardableResult
    func updateDriveFolderId(reportId: Int, folderId: String) -> Result<Void, Error> {
        self.database.updateDriveReportFolderId(idReport: reportId, folderId: folderId)
    }
    
    @discardableResult
    func updateDriveFiles(reportId: Int, files: [ReportFile]) -> Result<Void, Error> {
        self.database.updateDriveReportFiles(files: files, reportId: reportId)
    }
    
    @discardableResult
    func updateDriveFile(file: ReportFile) -> Result<Void, Error> {
        self.database.updateDriveFile(reportFile: file)
    }
    
}
