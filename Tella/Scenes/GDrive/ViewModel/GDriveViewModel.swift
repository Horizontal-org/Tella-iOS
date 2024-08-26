//
//  GDriveViewModel.swift
//  Tella
//
//  Created by gus valbuena on 6/12/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
class GDriveViewModel: ReportsMainViewModel {
    @Published var selectedReport: GDriveReport?
    @Published var server: GDriveServer?

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
        super.init(mainAppModel: mainAppModel, connectionType: .gDrive, title: LocalizableGDrive.gDriveAppBar.localized)
        
        self.getReports()
        self.getServer()
        self.listenToUpdates()
    }
    
    private func getServer() {
//        self.server = mainAppModel.tellaData?.gDriveServers.value.first
        self.server = mainAppModel.tellaData?.servers.first { $0 is GDriveServer } as? GDriveServer

    }
    
    override func getReports() {
        getDraftReports()
        getOutboxedReports()
        getSubmittedReports()
    }
    
    func getDraftReports() {
        let draftReports = tellaData?.getDraftGDriveReport() ?? []
        self.draftReportsViewModel = draftReports.compactMap { report in
            return ReportCardViewModel(report: report,
                                       serverName: server?.name,
                                       deleteReport: { self.deleteReport(report: report) },
                                       connectionType: .gDrive
            )
        }
    }
    
    func getOutboxedReports() {
        let outboxedReports = tellaData?.getOutboxedGDriveReport() ?? []
        self.outboxedReportsViewModel = outboxedReports.compactMap { report in
            ReportCardViewModel(report: report,
                                serverName: server?.name,
                                deleteReport: { self.deleteReport(report: report) },
                                connectionType: .gDrive
            )
        }
    }
    
    func getSubmittedReports() {
        let submittedReports = tellaData?.getSubmittedGDriveReport() ?? []
        self.submittedReportsViewModel = submittedReports.compactMap { report in
            ReportCardViewModel(report: report,
                                serverName: server?.name,
                                deleteReport: { self.deleteReport(report: report) },
                                connectionType: .gDrive
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
