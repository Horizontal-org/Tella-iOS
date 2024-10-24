//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ReportsViewModel: ReportsMainViewModel {
    @Published var selectedReport : Report?
    
    var sheetItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "view-icon",
                            content: self.selectedReport?.status.sheetItemTitle ?? "",
                            type: self.selectedReport?.status.reportActionType ?? .viewSubmitted),
        ListActionSheetItem(imageName: "delete-icon-white",
                            content: LocalizableReport.viewModelDelete.localized,
                            type: ConnectionActionType.delete)
    ]}
    
    private var delayTime = 0.1
    
    init(mainAppModel : MainAppModel) {
        super.init(mainAppModel: mainAppModel, connectionType: .tella, title: LocalizableReport.reportsTitle.localized)
        self.listenToUpdates()
    }
    
    override func getReports() {
        getDraftReports()
        getOutboxedReports()
        getSubmittedReports()
    }
    
    func getDraftReports() {
        let draftReports = tellaData?.getDraftReports() ?? []
        
        self.draftReportsViewModel = draftReports.compactMap { report in
            ReportCardViewModel(report: report,
                                serverName: report.server?.name,
                                deleteReport: { self.deleteReport(report: report) },
                                connectionType: .tella
            )
        }
    }
    
    func getOutboxedReports() {
        let outboxedReports = tellaData?.getOutboxedReports() ?? []
        
        self.outboxedReportsViewModel = outboxedReports.compactMap { report in
            ReportCardViewModel(report: report,
                                serverName: report.server?.name,
                                deleteReport: { self.deleteReport(report: report) }, connectionType: .tella
            )
        }
    }
    
    func getSubmittedReports() {
        let submittedReports = tellaData?.getSubmittedReports() ?? []
        
        self.submittedReportsViewModel = submittedReports.compactMap { report in
            ReportCardViewModel(report: report,
                                serverName: report.server?.name,
                                deleteReport: { self.deleteReport(report: report) },
                                connectionType: .tella)
        }
    }
    
    func deleteReport(report: Report) {
        let deleteReportResult = mainAppModel.deleteReport(reportId: report.id)
        handleDeleteReport(title: report.title, result: deleteReportResult)
    }
    
    override func deleteSubmittedReports() {
        let deleteResult = mainAppModel.tellaData?.deleteSubmittedReports()
        self.handleDeleteSubmittedReport(deleteResult: deleteResult)
    }
    
    override func listenToUpdates() {
        self.mainAppModel.tellaData?.shouldReloadTellaReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.getReports()
            }.store(in: &subscribers)
    }
    
}
