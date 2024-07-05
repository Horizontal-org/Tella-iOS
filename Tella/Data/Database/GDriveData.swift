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
        
        getGDriveReports()
        
        return id
    }
    
    func getGDriveReports() {
        DispatchQueue.main.async {
            self.gDriveDraftReports.value = self.database.getDriveReports(reportStatus: [ReportStatus.draft])
            self.gDriveOutboxedReports.value = self.database.getDriveReports(reportStatus: [.finalized,
                                                                                            .submissionError,
                                                                                            .submissionPending,
                                                                                            .submissionPaused,
                                                                                            .submissionInProgress,
                                                                                            .submissionAutoPaused,
                                                                                            .submissionScheduled])
            self.gDriveSubmittedReports.value = self.database.getDriveReports(reportStatus: [ReportStatus.submitted])
        }
    }
    
    func getDraftGDriveReport() -> [GDriveReport] {
        return self.database.getDriveReports(reportStatus: [ReportStatus.draft])
    }
    
    func getDriveReport(id: Int) -> GDriveReport? {
        self.database.getGDriveReport(id: id)
    }
    
    func updateDriveReport(report: GDriveReport) -> Result<Bool, Error> {
        getGDriveReports()
        return self.database.updateDriveReport(report: report)
    }
    
    func deleteDriveReport(reportId: Int?) -> Result<Bool, Error> {
        getGDriveReports()
        return self.database.deleteDriveReport(reportId: reportId)
    }
}
