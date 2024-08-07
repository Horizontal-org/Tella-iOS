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

    override init(mainAppModel: MainAppModel, reportsViewModel : ReportsMainViewModel, reportId : Int?) {

        super.init(mainAppModel: mainAppModel, reportsViewModel: reportsViewModel, reportId: reportId)

        if reportViewModel.status == .submissionScheduled {
            self.submitReport()
        } else {
            treat(uploadResponse:reportRepository.checkUploadReportOperation(reportId: self.reportViewModel.id))
        }
    }
    
    private func treat(uploadResponse: CurrentValueSubject<UploadResponse?,APIError>?) {
        uploadResponse?
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
                            file?.bytesSent = (progressInfo.total) ?? 0
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
        
        if let reportId, let report = self.mainAppModel.tellaData?.getReport(reportId: reportId) {

            let vaultFileResult  = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report.reportFiles?.compactMap{$0.fileId} ?? [])

            var files : [ReportVaultFile] = []
            
            report.reportFiles?.forEach({ reportFile in
                if let vaultFile = vaultFileResult?.first(where: {reportFile.fileId == $0.id}) {
                    let reportVaultFile = ReportVaultFile(reportFile: reportFile, vaultFile: vaultFile)
                    files.append(reportVaultFile)
                }
            })
            
            self.reportViewModel = ReportViewModel(id: report.id,
                                                   title: report.title ?? "",
                                                   description: report.description ?? "",
                                                   files: files,
                                                   reportFiles: report.reportFiles ?? [],
                                                   server: report.server,
                                                   status: report.status,
                                                   apiID: report.apiID)
        }
    }
    
    override func pauseSubmission() {
        if isSubmissionInProgress {
            self.updateReportStatus(reportStatus: .submissionPaused)
            self.reportRepository.pause(reportId: self.reportViewModel.id)
        }
        
    }
    
    override func submitReport() {
        
        let report = Report(id: reportViewModel.id,
                            title: reportViewModel.title,
                            description: reportViewModel.description,
                            status: reportViewModel.status,
                            server: reportViewModel.server,
                            vaultFiles: self.reportViewModel.reportFiles,
                            
                            apiID: self.reportViewModel.apiID)
        
        if isSubmissionInProgress == false {
            self.updateReportStatus(reportStatus: .submissionInProgress)
            
            guard let reportID = reportViewModel.id,
                  let report = self.mainAppModel.tellaData?.getReport(reportId:reportID) else { return }

            treat(uploadResponse: self.reportRepository.sendReport(report: report, mainAppModel: mainAppModel))
        }
    }
    
    override func updateCurrentFile(uploadProgressInfo : UploadProgressInfo) {
        self.reportViewModel.files = self.reportViewModel.files.compactMap { file in
            guard file.id == uploadProgressInfo.fileId else { return file }
            
            let updatedFile = file
            updatedFile.bytesSent = uploadProgressInfo.bytesSent ?? 0
            updatedFile.status = uploadProgressInfo.status
            return updatedFile
        }
    }


    // MARK: Update Local database
    
    override func updateReportStatus(reportStatus:ReportStatus) {
        
        self.reportViewModel.status = reportStatus
        
        guard let id = reportViewModel.id else { return  }

        mainAppModel.tellaData?.updateReportStatus(idReport: id, status: reportStatus)
    }
    
    override func deleteReport() {
        let deleteResult = mainAppModel.deleteReport(reportId: reportViewModel.id)
        handleDeleteReport(deleteResult: deleteResult)
    }
}
