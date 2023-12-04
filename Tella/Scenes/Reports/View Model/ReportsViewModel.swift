//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ReportsViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published var draftReports : [Report] = []
    @Published var outboxedReports : [Report] = []
    @Published var submittedReports : [Report] = []
    @Published var selectedReport : Report?
    @Published var selectedCell = Pages.draft

    var pageViewItems : [PageViewItem] {
        [PageViewItem(title: LocalizableReport.draftTitle.localized, page: .draft, number: draftReports.count),
         PageViewItem(title: LocalizableReport.outboxTitle.localized, page: .outbox, number: outboxedReports.count),
         PageViewItem(title: LocalizableReport.submittedTitle.localized, page: .submitted, number: submittedReports.count)] }

    var sheetItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "view-icon",
                            content: self.selectedReport?.status?.sheetItemTitle ?? "",
                            type: self.selectedReport?.status?.reportActionType ?? .viewSubmitted),
        ListActionSheetItem(imageName: "delete-icon-white",
                            content: LocalizableReport.viewModelDelete.localized,
                            type: ReportActionType.delete)
    ]}
    
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel : MainAppModel) {
        
        self.mainAppModel = mainAppModel
        
        self.getReports()
    }
    
    private func getReports() {
        
        self.mainAppModel.vaultManager.tellaData?.draftReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.draftReports = draftReports
            }.store(in: &subscribers)
        
        self.mainAppModel.vaultManager.tellaData?.outboxedReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.outboxedReports = draftReports
            }.store(in: &subscribers)
        
        self.mainAppModel.vaultManager.tellaData?.submittedReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                DispatchQueue.main.async {
                    self.submittedReports = draftReports
                }
                
            }.store(in: &subscribers)
    }

    func deleteReport() {
        mainAppModel.deleteReport(reportId: selectedReport?.id)
    }
    
    func deleteSubmittedReport() {
        mainAppModel.vaultManager.tellaData?.deleteSubmittedReport()
    }
    
}
