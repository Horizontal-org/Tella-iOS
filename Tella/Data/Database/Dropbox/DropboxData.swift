//
//  DropboxData.swift
//  Tella
//
//  Created by gus valbuena on 9/9/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

extension TellaData {
    
    ///ADD
    func addDropboxReport(report: DropboxReport) -> Result<Int, Error> {
        database.addDropboxReport(report: report)
    }
    
    /// GET
    func getDropboxServers() -> [DropboxServer] {
        self.database.getDropboxServers()
    }
    
    func getDraftDropboxReports() -> [DropboxReport] {
        return self.database.getDropboxReports(reportStatus: [.draft])
    }
    
    func getOutboxedDropboxReports() -> [DropboxReport] {
        return self.database.getOutboxReports(tableName: D.tDropboxReport)
    }
    
    func getSubmittedDropboxReports() -> [DropboxReport] {
        return self.database.getDropboxReports(reportStatus: [.submitted])
    }
    
    func getDropboxReport(id: Int?) -> DropboxReport? {
        guard let id else { return nil }
        return self.database.getDropboxReport(id: id)
    }
    
    /// UPDATE
    func updateDropboxReport(report: DropboxReport) -> Result<Void, Error> {
        self.database.updateDropboxReport(report: report)
    }
    
    @discardableResult
    func updateDropboxReportStatus(reportId: Int, status: ReportStatus) -> Result<Void, Error> {
        self.database.updateDropboxReportStatus(idReport: reportId, status: status)
    }
    
    @discardableResult
    func updateDropboxReportWithoutFiles(report: DropboxReport) -> Result<Void,Error> {
        database.updateDropboxReportWithoutFiles(report: report)
    }
    
    @discardableResult
    func updateDropboxReportFile(file: DropboxReportFile) -> Result<Void, Error> {
        self.database.updateDropboxReportFile(reportFile: file)
    }

    ///  DELETE
    func deleteDropboxReport(reportId: Int?) -> Result<Void, Error> {
        let deleteDropboxReportResult = self.database.deleteDropboxReport(reportId: reportId)
        shouldReloadDropboxReports.send(true)
        return deleteDropboxReportResult
    }
    
    @discardableResult
    func deleteDropboxSubmittedReports() -> Result<Void,Error> {
        let deleteSubmittedReportResult = database.deleteDropboxSubmittedReports()
        shouldReloadDropboxReports.send(true)
        return deleteSubmittedReportResult
    }

}
