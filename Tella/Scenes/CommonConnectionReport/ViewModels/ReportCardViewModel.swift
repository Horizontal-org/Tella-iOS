//
//  ReportCardViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 1/7/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation


class ReportCardViewModel: CommonCardViewModel {
    
    var status : ReportStatus = ReportStatus.unknown
    
    init(report : BaseReport,
         serverName : String?,
         deleteReport: @escaping (() -> Void),
         connectionType: ServerConnectionType = .uwazi) {
        
        let title = report.title ?? ""
        let subtitle = report.getReportDate
        let serverName = serverName
        let listActionSheetItem = report.status.listActionSheetItem
        let deleteReportStrings = report.status.deleteReportStrings
        
        super.init(id: report.id,
                   title: title,
                   subtitle: subtitle,
                   iconImageName: nil,
                   serverName: serverName,
                   updatedAt: report.updatedDate?.getModifiedReportTime(),
                   listActionSheetItem: listActionSheetItem,
                   connectionType: connectionType,
                   deleteReportStrings: deleteReportStrings,
                   deleteAction:deleteReport)
        
        self.deleteAction = deleteReport
        self.status = report.status
    }
}
