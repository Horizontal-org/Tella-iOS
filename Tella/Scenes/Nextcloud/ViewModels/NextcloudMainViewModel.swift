//
//  GDriveMainViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 2/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class NextcloudMainViewModel: ReportMainViewModel {
    
    override func getReports() {
        
        let draftReports =  tellaData?.database.getDraftGDriveReports() ?? []
        let outboxedReports = tellaData?.database.getDraftGDriveReports() ?? []
        let submittedReports = tellaData?.database.getDraftGDriveReports() ?? []
        
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
    
    func deleteReport(report:GDriveReport) {
        guard let reportId = report.id else { return }
        //        let resultDeletion = self.tellaData?.deleteGDriveReport(reportId: reportId)
        var message = ""
        //        if case .success = resultDeletion {
        //            message = String.init(format: LocalizableUwazi.uwaziDeletedToast.localized, entity.title ?? "")
        //        } else {
        //            message = LocalizableCommon.commonError.localized
        //        }
        
        self.shouldShowToast = true
        self.toastMessage = message
    }
}
