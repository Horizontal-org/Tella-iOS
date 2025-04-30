//
//  DropboxSubmittedViewModel.swift
//  Tella
//
//  Created by gus valbuena on 9/19/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class DropboxSubmittedViewModel: SubmittedMainViewModel {
    
    override init(reportsMainViewModel: ReportsMainViewModel, reportId: Int?) {
        super.init(reportsMainViewModel: reportsMainViewModel, reportId: reportId)
        fillReportVM(reportId: reportId)
    }
    
    override var report: BaseReport? {
        self.mainAppModel.tellaData?.getDropboxReport(id: self.id)
    }

    override func deleteReport() {
        guard
            let deleteResult = mainAppModel.tellaData?.deleteDropboxReport(reportId: id)
        else {
            return
        }
        handleDeleteReport(deleteResult: deleteResult )
    }
}
