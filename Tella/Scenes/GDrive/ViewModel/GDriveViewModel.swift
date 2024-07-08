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
    }
    
    override func getReports() {
        getDraftReports()
        getOutboxedReports()
        getSubmittedReports()
    }
    
    func getDraftReports() {
        self.mainAppModel.tellaData?.gDriveDraftReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.draftReportsViewModel = draftReports.compactMap { report in
                    ReportCardViewModel(report: report,
                                        serverName: report.server?.name,
                                        deleteReport: { self.deleteReport(report: report) }
                    )
                }
            }.store(in: &subscribers)
    }
    
    func getOutboxedReports() {
        self.mainAppModel.tellaData?.gDriveOutboxedReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { outboxedReports in
                self.outboxedReportsViewModel = outboxedReports.compactMap { report in
                    ReportCardViewModel(report: report,
                                        serverName: report.server?.name,
                                        deleteReport: { self.deleteReport(report: report) }
                    )
                }
            }.store(in: &subscribers)
    }
    
    func getSubmittedReports() {
        self.mainAppModel.tellaData?.gDriveSubmittedReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { submittedReports in
                self.submittedReportsViewModel = submittedReports.compactMap { report in
                    ReportCardViewModel(report: report,
                                        serverName: report.server?.name,
                                        deleteReport: { self.deleteReport(report: report) }
                    )
                }
            }.store(in: &subscribers)
    }
    
    func deleteReport(report: GDriveReport) {
        let _ = self.mainAppModel.tellaData?.deleteDriveReport(reportId: report.id)
    }
}
