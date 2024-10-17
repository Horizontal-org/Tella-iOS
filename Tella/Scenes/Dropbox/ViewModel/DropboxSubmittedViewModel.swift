//
//  DropboxSubmittedViewModel.swift
//  Tella
//
//  Created by gus valbuena on 9/19/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
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
        let _ = mainAppModel.tellaData?.deleteDropboxReport(reportId: id)
    }
}
