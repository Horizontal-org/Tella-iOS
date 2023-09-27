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
    @Published var selectedCell: Int = ReportPages.draft.rawValue
    @Published var pageViewItems : [PageViewItem] = [PageViewItem(title: LocalizableReport.draftTitle.localized, page: ReportPages.draft.rawValue, number: "") ,
                                                     PageViewItem(title: LocalizableReport.outboxTitle.localized, page: ReportPages.outbox.rawValue, number: ""),
                                                     PageViewItem(title: LocalizableReport.submittedTitle.localized, page: ReportPages.submitted.rawValue, number: "")]
    
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
                self.updateDraftReportsNumber()
                
            }.store(in: &subscribers)
        
        self.mainAppModel.vaultManager.tellaData?.outboxedReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.outboxedReports = draftReports
                self.updateOutboxReportsNumber()
                
            }.store(in: &subscribers)
        
        self.mainAppModel.vaultManager.tellaData?.submittedReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.submittedReports = draftReports
                self.updateSubmittedReportsNumber()
                
            }.store(in: &subscribers)
    }
    
    private func updateDraftReportsNumber() {
        if let row = self.pageViewItems.firstIndex(where: {$0.page == ReportPages.draft.rawValue}) {
            if draftReports.count > 0 {
                pageViewItems[row].number = "(\(draftReports.count))"
            }
            else {
                pageViewItems[row].number = ""
            }
        }
    }
    
    private func updateOutboxReportsNumber() {
        if let row = self.pageViewItems.firstIndex(where: {$0.page == ReportPages.outbox.rawValue}) {
            
            if outboxedReports.count > 0 {
                pageViewItems[row].number = "(\(outboxedReports.count))"
            }
            else {
                pageViewItems[row].number = ""
            }
        }
    }
    
    private func updateSubmittedReportsNumber() {
        if let row = self.pageViewItems.firstIndex(where: {$0.page == ReportPages.submitted.rawValue}) {
            
            if submittedReports.count > 0 {
                pageViewItems[row].number = "(\(submittedReports.count))"
            }
            else {
                pageViewItems[row].number = ""
            }
        }
    }
    
    func deleteReport() {
        mainAppModel.deleteReport(reportId: selectedReport?.id)
    }
    
    func deleteSubmittedReport() {
        mainAppModel.vaultManager.tellaData?.deleteSubmittedReport()
    }
    
}
