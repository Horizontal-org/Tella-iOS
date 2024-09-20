//
//  DropboxData.swift
//  Tella
//
//  Created by gus valbuena on 9/9/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension TellaData {
    
    ///ADD
    func addDropboxReport(report: DropboxReport) -> Result<Int, Error> {
        let id = database.addDropboxReport(report: report)
        
        shouldReloadDropboxReports.send(true)
        
        return id
    }
    
    /// GET
    func getDropboxServers() -> [DropboxServer] {
        self.database.getDropboxServers()
    }
    
    func getDraftDropboxReports() -> [DropboxReport] {
        return self.database.getDropboxReports(reportStatus: [.draft])
    }
    
    func getOutboxedDropboxReports() -> [DropboxReport] {
        return self.database.getDropboxReports(reportStatus: [.finalized,
                                                              .submissionError,
                                                              .submissionPending,
                                                              .submissionPaused,
                                                              .submissionInProgress,
                                                              .submissionAutoPaused,
                                                              .submissionScheduled])
    }
    
    func getSubmittedDropboxReports() -> [DropboxReport] {
        return self.database.getDropboxReports(reportStatus: [.submitted])
    }
    
    func getDropboxReport(id: Int?) -> DropboxReport? {
        guard let id else { return nil }
        return self.database.getDropboxReport(id: id)
    }
    
    /// UPDATE
    func updateDropboxReport(report: DropboxReport) -> Result<Bool, Error> {
        shouldReloadDropboxReports.send(true)
        
        return self.database.updateDropboxReport(report: report)
    }
    
    @discardableResult
    func updateDropboxReportStatus(reportId: Int, status: ReportStatus) -> Result<Bool, Error> {
        shouldReloadDropboxReports.send(true)
        
        return self.database.updateDropboxReportStatus(idReport: reportId, status: status)
    }
    
    @discardableResult
    func updateDropboxFiles(reportId: Int, files: [ReportFile]) -> Result<Bool, Error> {
        shouldReloadDropboxReports.send(true)
        
        return self.database.updateDropboxReportFiles(files: files, reportId: reportId)
    }
    
    ///  DELETE
    func deleteDropboxReport(reportId: Int?) -> Result<Bool, Error> {
        shouldReloadDropboxReports.send(true)
        
        return self.database.deleteDropboxReport(reportId: reportId)
    }
}
