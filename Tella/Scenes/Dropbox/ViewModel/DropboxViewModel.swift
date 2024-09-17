//
//  DropboxViewModel.swift
//  Tella
//
//  Created by gus valbuena on 9/12/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class DropboxViewModel: ReportsMainViewModel {
    var dropboxRepository: DropboxRepositoryProtocol
    
    @Published var selectedReport: DropboxReport?
    @Published var server: DropboxServer?
    
    var sheetItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "view-icon",
                            content: self.selectedReport?.status.sheetItemTitle ?? "",
                            type: self.selectedReport?.status.reportActionType ?? .viewSubmitted),
        ListActionSheetItem(imageName: "delete-icon-white",
                            content: LocalizableReport.viewModelDelete.localized,
                            type: ConnectionActionType.delete)
    ]}

    
    init(mainAppModel: MainAppModel, dropboxRepository: DropboxRepositoryProtocol) {
        self.dropboxRepository = dropboxRepository
        super.init(mainAppModel: mainAppModel, connectionType: .dropbox, title: LocalizableDropbox.dropboxAppBar.localized)
        
        self.getReports()
        self.getServer()
        self.listenToUpdates()
    }
    
    private func getServer() {
        self.server = mainAppModel.tellaData?.getDropboxServers().first
    }
    
    override func getReports() {
        getDraftReports()
        getOutboxedReports()
        getSubmittedReports()
    }
    
    func getDraftReports() {
        let draftReports = tellaData?.getDraftDropboxReports() ?? []
        self.draftReportsViewModel = draftReports.compactMap { report in
            return ReportCardViewModel(report: report,
                                       serverName: server?.name,
                                       deleteReport: { self.deleteReport(report: report) },
                                       connectionType: .gDrive
            )
        }
    }
        
    func getOutboxedReports() {
        let outboxedReports = tellaData?.getOutboxedDropboxReports() ?? []
        self.outboxedReportsViewModel = outboxedReports.compactMap { report in
            ReportCardViewModel(report: report,
                                serverName: server?.name,
                                deleteReport: { self.deleteReport(report: report) },
                                connectionType: .gDrive
            )
        }
    }
        
    func getSubmittedReports() {
        let submittedReports = tellaData?.getSubmittedDropboxReports() ?? []
        self.submittedReportsViewModel = submittedReports.compactMap { report in
            ReportCardViewModel(report: report,
                                serverName: server?.name,
                                deleteReport: { self.deleteReport(report: report) },
                                connectionType: .gDrive
            )
        }
    }
    
    func deleteReport(report: DropboxReport) {
        let _ = self.mainAppModel.tellaData?.deleteDropboxReport(reportId: report.id)
    }
    
    override func listenToUpdates() {
        self.mainAppModel.tellaData?.shouldReloadDropboxReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.getReports()
            }.store(in: &subscribers)
    }
}
