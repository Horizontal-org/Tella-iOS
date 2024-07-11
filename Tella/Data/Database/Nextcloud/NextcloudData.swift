//
//  NextcloudData.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

extension TellaData {
    
    func addNextcloudReport(report : NextcloudReport) -> Int? {
        let id =  database.addNextcloudReport(report: report)
        shouldReloadNextcloudReports.send(true)
        return id
    }
    
    func getDraftNextcloudReport() -> [NextcloudReport] {
        return self.database.getNextcloudReports(reportStatus: [ReportStatus.draft])
    }
    
    func getOutboxedNextcloudReport() -> [NextcloudReport] {
        return self.database.getNextcloudReports(reportStatus: [.finalized,
                                                                .submissionError,
                                                                .submissionPending,
                                                                .submissionPaused,
                                                                .submissionInProgress,
                                                                .submissionAutoPaused,
                                                                .submissionScheduled])
    }
    
    func getSubmittedNextcloudReport() -> [NextcloudReport] {
        return self.database.getNextcloudReports(reportStatus: [ReportStatus.submitted])
    }
    
    func getNextcloudReport(id: Int) -> NextcloudReport? {
        self.database.getNextcloudReport(id: id)
    }
    
    func updateNextcloudReport(report: NextcloudReport) -> Bool {
        shouldReloadNextcloudReports.send(true)
        return self.database.updateNextcloudReport(report: report)
    }
    
    func deleteNextcloudReport(reportId: Int?) -> Bool {
        shouldReloadNextcloudReports.send(true)
        return self.database.deleteNextcloudReport(reportId: reportId)
    }
}
