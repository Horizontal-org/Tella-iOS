//
//  NextcloudReportViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 2/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class NextcloudReportViewModel: ReportsMainViewModel {
    
    var nextcloudRepository: NextcloudRepositoryProtocol
    
    init(mainAppModel: MainAppModel, nextcloudRepository: NextcloudRepositoryProtocol) {
        self.nextcloudRepository = nextcloudRepository
        super.init(mainAppModel: mainAppModel, connectionType: .nextcloud, title: LocalizableNextcloud.nextcloudAppBar.localized)
    }
    
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
        self.mainAppModel.tellaData?.shouldReloadNextcloudReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.getReports()
            }.store(in: &subscribers)
    }
    
    func deleteReport(report:NextcloudReport) {
        let resultDeletion = self.tellaData?.deleteNextcloudReport(reportId: report.id)
        self.handleDeleteReport(title: report.title ?? "", result: resultDeletion)
    }
    
    override func deleteSubmittedReports() {
        let deleteResult = mainAppModel.tellaData?.deleteNextcloudSubmittedReports()  
        self.handleDeleteSubmittedReport(deleteResult: deleteResult)
    }
}
