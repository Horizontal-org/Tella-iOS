//
//  GDriveViewModel.swift
//  Tella
//
//  Created by gus valbuena on 6/12/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine
class GDriveViewModel: ReportsMainViewModel {
    @Published var selectedReport: GDriveReport?
    @Published var server: GDriveServer?
    
    private var delayTime = 0.1
    var gDriveRepository: GDriveRepositoryProtocol
    var sheetItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "view-icon",
                            content: self.selectedReport?.status.sheetItemTitle ?? "",
                            type: self.selectedReport?.status.reportActionType ?? .viewSubmitted),
        ListActionSheetItem(imageName: "delete-icon-white",
                            content: LocalizableReport.viewModelDelete.localized,
                            type: ConnectionActionType.delete)
    ]}
    
    
    init(mainAppModel: MainAppModel, gDriveRepository: GDriveRepositoryProtocol) {
        self.gDriveRepository = gDriveRepository
        super.init(mainAppModel: mainAppModel, connectionType: .gDrive, title: LocalizableGDrive.gDriveAppBar.localized)
        
        self.getServer()
        self.listenToUpdates()
    }
    
    private func getServer() {
        self.server = mainAppModel.tellaData?.getDriveServers().first
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
        let deleteDriveReportResult = self.mainAppModel.tellaData?.deleteDriveReport(reportId: report.id)
        handleDeleteReport(title: report.title, result: deleteDriveReportResult)
    }
    
    override func deleteSubmittedReports() {
        let deleteResult = mainAppModel.tellaData?.deleteDriveSubmittedReports()
        self.handleDeleteSubmittedReport(deleteResult: deleteResult)
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
