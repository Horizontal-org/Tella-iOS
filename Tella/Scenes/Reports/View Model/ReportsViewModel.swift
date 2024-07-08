//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ReportsViewModel: ReportMainViewModel {
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
        
        self.getReports()
    }
    
    override func getReports() {
        getDraftReports()
        getOutboxedReports()
        getSubmittedReports()
    }
    
    func getDraftReports() {
        self.mainAppModel.tellaData?.draftReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.draftReportsViewModel = draftReports.compactMap { report in
                    ReportCardViewModel(report: report,
                                        serverName: report.server?.name,
                                        deleteReport: { self.deleteReport(report: report) },
                                        connectionType: .tella
                    )
                }
            }.store(in: &subscribers)
    }
    
    func getOutboxedReports() {
        self.mainAppModel.tellaData?.outboxedReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { outboxedReports in
                self.outboxedReportsViewModel = outboxedReports.compactMap { report in
                    ReportCardViewModel(report: report,
                                        serverName: report.server?.name,
                                        deleteReport: { self.deleteReport(report: report) }, connectionType: .tella
                    )
                }
                
            }.store(in: &subscribers)
    }
    
    func getSubmittedReports() {
        self.mainAppModel.tellaData?.submittedReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { submittedReports in
                self.submittedReportsViewModel = submittedReports.compactMap { report in
                    ReportCardViewModel(report: report,
                                        serverName: report.server?.name,
                                        deleteReport: { self.deleteReport(report: report) },
                                        connectionType: .tella
                    )
                }
            }.store(in: &subscribers)
    }
    
    func deleteReport(report: Report) {
        mainAppModel.deleteReport(reportId: report.id)
    }
    
    func deleteSubmittedReport() {
        mainAppModel.tellaData?.deleteSubmittedReport()
    }
    
}
