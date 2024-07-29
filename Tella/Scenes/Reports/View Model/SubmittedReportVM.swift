//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class SubmittedReportVM: SubmittedMainViewModel {
    
    override init(mainAppModel: MainAppModel, reportId: Int?) {
        super.init(mainAppModel: mainAppModel, reportId: reportId)
        fillReportVM(reportId: reportId)
    }
    
    override var report: BaseReport? {
        self.mainAppModel.tellaData?.getReport(reportId: self.id)
    }
    
    override func deleteReport() {
        mainAppModel.deleteReport(reportId: id)
    }
}
