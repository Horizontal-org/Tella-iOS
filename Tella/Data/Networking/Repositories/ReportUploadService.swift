//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Combine

class ReportUploadService {

    func sendReport(report: Report, mainAppModel: MainAppModel) -> CurrentValueSubject<UploadResponse?, APIError> {
        return UploadService.shared.addUploadReportOperation(report: report, mainAppModel: mainAppModel)
    }

    func pause(reportId: Int?) {
        UploadService.shared.pauseDownload(reportId: reportId)
    }

    func checkUploadReportOperation(reportId: Int?) -> CurrentValueSubject<UploadResponse?, APIError>? {
        UploadService.shared.checkUploadReportOperation(reportId: reportId)
    }
}
