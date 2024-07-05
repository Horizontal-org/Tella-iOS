//
//  ReportCardViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 1/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation


class ReportCardViewModel: CommonCardViewModel {
    
    var status : ReportStatus = ReportStatus.unknown
    
    init(report : BaseReport,
         serverName : String?,
         deleteReport: @escaping (() -> Void),
         connectionType: ServerConnectionType = .uwazi
    ) {
        
        let title = report.title ?? ""
        let serverName = serverName
        let iconImageName : String? = report.status.iconImageName
        let listActionSheetItem = report.status.listActionSheetItem
        let deleteReportStrings = report.status.deleteReportStrings
        
        super.init(id: report.id ?? 0,
                   title: title,
                   iconImageName: iconImageName,
                   serverName: serverName,
                   listActionSheetItem: listActionSheetItem,
                   connectionType: connectionType,
                   deleteReportStrings: deleteReportStrings,
                   deleteAction:deleteReport)
        
        self.deleteAction = deleteReport
        self.status = report.status
    }
}
