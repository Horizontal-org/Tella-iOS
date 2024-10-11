//
//  NextcloudSubmittedViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 23/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class NextcloudSubmittedViewModel: SubmittedMainViewModel {
    
    override init(reportsMainViewModel: ReportsMainViewModel, reportId: Int?) {
        super.init(reportsMainViewModel: reportsMainViewModel, reportId: reportId)
        fillReportVM(reportId: reportId)
    }
    
    override var report: BaseReport? {
        return mainAppModel.tellaData?.getNextcloudReport(id: id)
    }
    
    override func deleteReport() {
        guard
            let deleteResult = mainAppModel.tellaData?.deleteNextcloudReport(reportId: id)
        else {
            return
        }
        handleDeleteReport(deleteResult: deleteResult )
    }

}
