//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Combine

protocol ReportUploadServiceProtocol {
    func sendReport(report: Report, mainAppModel: MainAppModel) -> CurrentValueSubject<UploadResponse?, APIError>
    func pause(reportId: Int?)
    func checkUploadReportOperation(reportId: Int?) -> CurrentValueSubject<UploadResponse?, APIError>?
}

class ReportUploadService: ReportUploadServiceProtocol {
    private let uploadService: UploadService
    
    init(uploadService: UploadService = .shared) {
        self.uploadService = uploadService
    }
    
    func sendReport(report: Report, mainAppModel: MainAppModel) -> CurrentValueSubject<UploadResponse?, APIError> {
        uploadService.addUploadReportOperation(report: report, mainAppModel: mainAppModel)
    }
    
    func pause(reportId: Int?) {
        uploadService.pauseUpload(reportId: reportId)
    }
    
    func checkUploadReportOperation(reportId: Int?) -> CurrentValueSubject<UploadResponse?, APIError>? {
        uploadService.checkUploadReportOperation(reportId: reportId)
    }
}
