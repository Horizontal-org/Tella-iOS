//
//  UwaziViewModel.swift
//  Tella
//
//  Created by Gustavo on 31/07/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class UwaziReportsViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published var templates : [Report] = []
    @Published var draftReports : [Report] = []
    @Published var outboxedReports : [Report] = []
    @Published var submittedReports : [Report] = []
    @Published var selectedReport : Report?
    @Published var selectedCell = Pages.templates
    @Published var pageViewItems : [PageViewItem] = [
        PageViewItem(title: "Templates", page: .templates, number: ""),
        PageViewItem(title: LocalizableReport.draftTitle.localized, page: .draft, number: "") ,
        PageViewItem(title: LocalizableReport.outboxTitle.localized, page: .outbox, number: ""),
        PageViewItem(title: LocalizableReport.submittedTitle.localized, page: .submitted, number: "")
    ]
    
    var sheetItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "view-icon",
                            content: self.selectedReport?.status?.sheetItemTitle ?? "",
                            type: self.selectedReport?.status?.reportActionType ?? .viewSubmitted),
        ListActionSheetItem(imageName: "delete-icon-white",
                            content: LocalizableReport.viewModelDelete.localized,
                            type: ReportActionType.delete)
    ]}
    
    
    init(mainAppModel : MainAppModel) {
        
        self.mainAppModel = mainAppModel
    }
    

    
}
