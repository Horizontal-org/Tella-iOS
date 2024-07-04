//
//  GDriveViewModel.swift
//  Tella
//
//  Created by gus valbuena on 6/12/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
class GDriveViewModel: BaseReportsViewModel {
    
    @Published var draftReports: [GDriveReport] = []
    @Published var outboxedReports: [GDriveReport] = []
    @Published var submittedReports: [GDriveReport] = []
    
    @Published var selectedReport: GDriveReport?
    var pageViewItems: [PageViewItem] {
        [
            PageViewItem(title: LocalizableReport.draftTitle.localized,
                         page: .draft,
                        number: 0),
            PageViewItem(title: LocalizableReport.outboxTitle.localized,
                        page: .outbox,
                        number: 0),
            PageViewItem(title: LocalizableReport.submittedTitle.localized,
                        page: .submitted,
                        number: 0)]
    }
    
    private var subscribers = Set<AnyCancellable>()
    private var delayTime = 0.1
    
    var sheetItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "view-icon",
                            content: self.selectedReport?.status?.sheetItemTitle ?? "",
                            type: self.selectedReport?.status?.reportActionType ?? .viewSubmitted),
        ListActionSheetItem(imageName: "delete-icon-white",
                            content: LocalizableReport.viewModelDelete.localized,
                            type: ReportActionType.delete)
    ]}
    
    override init(mainAppModel: MainAppModel) {
        super.init(mainAppModel: mainAppModel)
        
        self.getReports()
    }
    
    private func getReports() {
        getDraftReports()
    }
    
    func getDraftReports() {
        self.mainAppModel.tellaData?.gDriveDraftReports
            .receive(on: DispatchQueue.main)
            .sink { result in
            } receiveValue: { draftReports in
                self.draftReports = []
                DispatchQueue.main.asyncAfter(deadline: .now() + self.delayTime, execute: {
                    self.draftReports = draftReports
                })
            }.store(in: &subscribers)
    }
    
    func deleteReport() {
        let _ = self.mainAppModel.tellaData?.deleteDriveReport(reportId: selectedReport?.id)
    }
}
