//
//  NextcloudReportViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 2/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class NextcloudReportViewModel: ReportMainViewModel {
    
    override func getReports() {
        
        let draftReports =  tellaData?.getDraftNextcloudReport() ?? []
        let outboxedReports = tellaData?.getOutboxedNextcloudReport() ?? []
        let submittedReports = tellaData?.getSubmittedNextcloudReport() ?? []
        
        draftReportsViewModel = draftReports.compactMap { report in
            ReportCardViewModel(report: report,
                                serverName: report.server?.name,
                                deleteReport: {self.deleteReport(report: report)})
        }
        
        outboxedReportsViewModel = outboxedReports.compactMap { report in
            ReportCardViewModel(report: report,
                                serverName: report.server?.name,
                                deleteReport: {self.deleteReport(report: report)})
        }
        
        submittedReportsViewModel = submittedReports.compactMap { report in
            ReportCardViewModel(report: report,
                                serverName: report.server?.name,
                                deleteReport: {self.deleteReport(report: report)})
        }
    }
    
    override func listenToUpdates() {
        self.mainAppModel.tellaData?.shouldReloadGDriveReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.getReports()
            }.store(in: &subscribers)
    }
    
    func deleteReport(report:NextcloudReport) {
        var message = ""
        
        guard let reportId = report.id else {
            message = LocalizableCommon.commonError.localized
            return }
        let resultDeletion = self.tellaData?.deleteNextcloudReport(reportId: reportId)
        message = String.init(format: LocalizableUwazi.uwaziDeletedToast.localized, report.title ?? "")
        
        self.shouldShowToast = true
        self.toastMessage = message
    }
}
