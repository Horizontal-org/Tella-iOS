//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine

class OutboxReportVM: OutboxMainViewModel<TellaServer> {    
    var reportRepository = ReportRepository()
    
    var reportIsNotAutoDelete: Bool {
        return !(reportViewModel.server?.autoDelete ?? true)
    }

    override init(reportsViewModel : ReportsMainViewModel, reportId : Int?) {

        super.init(reportsViewModel: reportsViewModel, reportId: reportId)

        if reportViewModel.status == .submissionScheduled {
            self.submitReport()
        } else {
            treat(uploadResponse:reportRepository.checkUploadReportOperation(reportId: self.reportViewModel.id))
        }
    }
    
    private func treat(uploadResponse: CurrentValueSubject<UploadResponse?,APIError>?) {
        uploadResponse?
            .receive(on: DispatchQueue.main)
            .sink { result in
                
            } receiveValue: { response in
                
                switch response {
                    
                case .createReport(let apiId, let reportStatus, let error):
                    
                    if let _ = error {
                        
                    } else {
                        
                        self.reportViewModel.apiID = apiId
                        self.reportViewModel.status = reportStatus
                        
                        if self.reportViewModel.files.isEmpty {
                            self.showSubmittedReport()
                        }
                    }
                    
                case .progress(let progressInfo):
                    
                    if let _ = progressInfo.error {
                        
                    } else {
                        
                        _ =  self.reportViewModel.files.compactMap { _ in
                            let file = self.reportViewModel.files.first(where: {$0.id == progressInfo.fileId})
                            file?.bytesSent = (progressInfo.bytesSent) ?? 0
                            file?.status = progressInfo.status
                            return file
                        }
                        
                        self.updateProgressInfos(uploadProgressInfo: progressInfo)
                        
                        if let reportStatus = progressInfo.reportStatus {
                            self.reportViewModel.status = reportStatus
                        }
                    }
                case .finish(let isAutoDelete, _):
                    DispatchQueue.main.async {
                        if isAutoDelete {
                            self.showMainView()
                        } else {
                            self.showSubmittedReport()
                        }
                    }
                default:
                    break
                }
            }
            .store(in: &subscribers)
    }
    
    override func initVaultFile(reportId: Int?) {
        
        if let reportId, let report = self.reportsViewModel.mainAppModel.tellaData?.getReport(reportId: reportId) {

            let files = processVaultFiles(reportFiles: report.reportFiles)
            
            self.reportViewModel = ReportViewModel(report: report, files: files)
        }
    }
    
    override func pauseSubmission() {
        if isSubmissionInProgress {
            self.updateReportStatus(reportStatus: .submissionPaused)
            self.reportRepository.pause(reportId: self.reportViewModel.id)
        }
        
    }
    
    override func submitReport() {
        if isSubmissionInProgress == false {
            self.updateReportStatus(reportStatus: .submissionInProgress)
            
            guard let reportID = reportViewModel.id,
                  let report = self.mainAppModel.tellaData?.getReport(reportId:reportID) else { return }

            treat(uploadResponse: self.reportRepository.sendReport(report: report, mainAppModel: mainAppModel))
        }
    }

    // MARK: Update Local database
    
    override func updateReportStatus(reportStatus:ReportStatus) {
        
        self.reportViewModel.status = reportStatus
        self.objectWillChange.send()

        guard let id = reportViewModel.id else { return  }

        mainAppModel.tellaData?.updateReportStatus(idReport: id, status: reportStatus)
    }
    
    override func deleteReport() {
        guard
            let deleteResult = mainAppModel.deleteReport(reportId: reportViewModel.id)
        else {
            return
        }
        handleDeleteReport(deleteResult: deleteResult)
    }
}
