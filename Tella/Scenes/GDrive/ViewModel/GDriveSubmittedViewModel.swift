//
//  GDriveSubmittedViewModel.swift
//  Tella
//
//  Created by gus valbuena on 7/11/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class GDriveSubmittedViewModel: SubmittedMainViewModel {
    
    override init(mainAppModel: MainAppModel, reportId: Int?) {
        super.init(mainAppModel: mainAppModel, reportId: reportId)
        fillReportVM(reportId: reportId)
    }
    
    override var report: BaseReport? {
        self.mainAppModel.tellaData?.getDriveReport(id: self.id)
    }

    override func deleteReport() {
        let _ = mainAppModel.tellaData?.deleteDriveReport(reportId: id)
    }
}
