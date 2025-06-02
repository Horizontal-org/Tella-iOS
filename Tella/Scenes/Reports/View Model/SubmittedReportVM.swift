//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

class SubmittedReportVM: SubmittedMainViewModel {
    
    override init(reportsMainViewModel: ReportsMainViewModel, reportId: Int?) {
        super.init(reportsMainViewModel: reportsMainViewModel, reportId:reportId)
        fillReportVM(reportId: reportId)
    }
    
    override var report: BaseReport? {
        self.mainAppModel.tellaData?.getReport(reportId: self.id)
    }
    
    override func deleteReport() {
        guard
            let deleteResult = mainAppModel.deleteReport(reportId: id)
        else {
            return
        }
        handleDeleteReport(deleteResult: deleteResult )
    }
}
