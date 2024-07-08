//
//  GDriveViewModel.swift
//  Tella
//
//  Created by gus valbuena on 6/12/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
class GDriveViewModel: ReportMainViewModel {
    
    @Published var draftReports: [GDriveReport] = []
    @Published var outboxedReports: [GDriveReport] = []
    @Published var submittedReports: [GDriveReport] = []
    
    @Published var selectedReport: GDriveReport?


    private var delayTime = 0.1
    
    var sheetItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "view-icon",
                            content: self.selectedReport?.status.sheetItemTitle ?? "",
                            type: self.selectedReport?.status.reportActionType ?? .viewSubmitted),
        ListActionSheetItem(imageName: "delete-icon-white",
                            content: LocalizableReport.viewModelDelete.localized,
                            type: ConnectionActionType.delete)
    ]}
    
    init(mainAppModel: MainAppModel) {
        super.init(mainAppModel: mainAppModel, connectionType: .gDrive, title: "Google Drive")
        
        self.getReports()
        self.listenToUpdates()
    }
    
    override func getReports() {
        getDraftReports()
        getOutboxedReports()
        getSubmittedReports()
    }
    
    func getDraftReports() {
        let draftReports = tellaData?.getDraftGDriveReport() ?? []
        self.draftReportsViewModel = draftReports.compactMap { report in
            ReportCardViewModel(report: report,
                                serverName: report.server?.name,
                                deleteReport: { self.deleteReport(report: report) }
            )
        }
    }
    
    func getOutboxedReports() {
        let outboxedReports = tellaData?.getOutboxedGDriveReport() ?? []
        self.outboxedReportsViewModel = outboxedReports.compactMap { report in
            ReportCardViewModel(report: report,
                                serverName: report.server?.name,
                                deleteReport: { self.deleteReport(report: report) }
            )
        }
    }
    
    func getSubmittedReports() {
        let submittedReports = tellaData?.getSubmittedGDriveReport() ?? []
        self.submittedReportsViewModel = submittedReports.compactMap { report in
            ReportCardViewModel(report: report,
                                serverName: report.server?.name,
                                deleteReport: { self.deleteReport(report: report) }
            )
        }
    }
    
    func deleteReport(report: GDriveReport) {
        let _ = self.mainAppModel.tellaData?.deleteDriveReport(reportId: report.id)
    }
    
    override func listenToUpdates() {
        self.mainAppModel.tellaData?.shouldReloadGDriveReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.getReports()
            }.store(in: &subscribers)
    }
}
