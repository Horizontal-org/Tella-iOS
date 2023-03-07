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
    @Published var newReportRootLinkIsActive : Bool = false
    @Published var editRootLinkIsActive : Bool = false
    @Published var viewReportLinkIsActive : Bool = false
    @Published var selectedReport : Report?
    @Published var selectedCell = Pages.draft
    @Published var pageViewItems : [PageViewItem] = [PageViewItem(title: "Drafts", page: .draft, number: "") ,
                                                     PageViewItem(title: "Outbox", page: .outbox, number: ""),
                                                     PageViewItem(title: "Submitted", page: .submitted, number: "")]
    
    var nonSubmittedReportItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "edit-icon",
                            content: "Edit",
                            type: ReportActionType.edit),
        ListActionSheetItem(imageName: "delete-icon-white",
                            content: "Delete",
                            type: ReportActionType.delete)
    ]}
    
    var submittedReportItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "view-icon",
                            content: "View",
                            type: ReportActionType.view),
        ListActionSheetItem(imageName: "delete-icon-white",
                            content: "Delete",
                            type: ReportActionType.delete)
    ]}
    
    var serverLinkIsActive : Binding<Bool> = .constant(false)
    private var subscribers = Set<AnyCancellable>()
    
    var clickActionType : ReportActionType {
        switch self.selectedReport?.status {
        case .submitted:
            return.view
        default:
            return .edit
        }
    }

    init(mainAppModel : MainAppModel, serverLinkIsActive : Binding<Bool> = .constant(false)) {
        
        self.mainAppModel = mainAppModel
        
        self.getReports()
        
        self.serverLinkIsActive = serverLinkIsActive
    }
    
    private func getReports() {
        
        self.mainAppModel.vaultManager.tellaData.draftReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.draftReports = draftReports
                self.updateDraftReportsNumber()
                
            }.store(in: &subscribers)
        
        self.mainAppModel.vaultManager.tellaData.outboxedReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.outboxedReports = draftReports
                self.updateOutboxReportsNumber()
                
            }.store(in: &subscribers)
        
        self.mainAppModel.vaultManager.tellaData.submittedReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.submittedReports = draftReports
                self.updateSubmittedReportsNumber()
                
            }.store(in: &subscribers)
    }
    
    private func updateDraftReportsNumber() {
        if let row = self.pageViewItems.firstIndex(where: {$0.page == .draft}) {
            if draftReports.count > 0 {
                pageViewItems[row].number = "(\(draftReports.count))"
            }
            else {
                pageViewItems[row].number = ""
            }
        }
    }
    
    private func updateOutboxReportsNumber() {
        if let row = self.pageViewItems.firstIndex(where: {$0.page == .outbox}) {
            
            if outboxedReports.count > 0 {
                pageViewItems[row].number = "(\(outboxedReports.count))"
            }
            else {
                pageViewItems[row].number = ""
            }
        }
    }
    
    private func updateSubmittedReportsNumber() {
        if let row = self.pageViewItems.firstIndex(where: {$0.page == .submitted}) {
            
            if submittedReports.count > 0 {
                pageViewItems[row].number = "(\(submittedReports.count))"
            }
            else {
                pageViewItems[row].number = ""
            }
        }
    }
    
    func deleteReport() {
        do {
            try _ = mainAppModel.vaultManager.tellaData.deleteReport(reportId: selectedReport?.id)
        } catch {
            
        }
    }
}
