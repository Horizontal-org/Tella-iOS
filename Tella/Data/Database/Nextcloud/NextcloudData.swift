//
//  NextcloudData.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

extension TellaData {
    
    func getNextcloudServer() -> [NextcloudServer] {
        self.database.getNextcloudServer()
    }
    
    func addNextcloudReport(report : NextcloudReport) -> Int? {
        database.addNextcloudReport(report: report)
    }
    
    func getDraftNextcloudReport() -> [NextcloudReport] {
        return self.database.getNextcloudReports(reportStatus: [ReportStatus.draft])
    }
    
    func getOutboxedNextcloudReport() -> [NextcloudReport] {
        return self.database.getOutboxReports(tableName: D.tNextcloudReport)
    }
    
    func getSubmittedNextcloudReport() -> [NextcloudReport] {
        return self.database.getNextcloudReports(reportStatus: [ReportStatus.submitted])
    }
    
    func getNextcloudReport(id: Int?) -> NextcloudReport? {
        guard let id else { return nil }
        return self.database.getNextcloudReport(id: id)
    }
    
    func updateNextcloudReport(report: NextcloudReport) -> Result<Void,Error> {
        self.database.updateNextcloudReport(report: report)
    }
    
    func deleteNextcloudReport(reportId: Int?) -> Result<Void,Error> {
        let deleteNextcloudReportResult = self.database.deleteNextcloudReport(reportId: reportId)
        shouldReloadNextcloudReports.send(true)
        return deleteNextcloudReportResult
    }
    
    @discardableResult
    func updateNextcloudReportFile(reportFile: ReportFile) -> Result<Void,Error> {
        database.updateNextcloudReportFile(reportFile: reportFile)
    }
    
    @discardableResult
    func updateNextcloudReportWithoutFiles(report: NextcloudReport) -> Result<Void,Error> {
        database.updateNextcloudReportWithoutFiles(report: report)
    }
    
    @discardableResult
    func deleteNextcloudSubmittedReports() -> Result<Void,Error> {
        let deleteSubmittedReportResult = database.deleteNextcloudSubmittedReports()
        shouldReloadNextcloudReports.send(true)
        return deleteSubmittedReportResult
    }
}
