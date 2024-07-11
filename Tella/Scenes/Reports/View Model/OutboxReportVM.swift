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

    override init(mainAppModel: MainAppModel, reportsViewModel : ReportMainViewModel, reportId : Int?, shouldStartUpload: Bool = false) {

        super.init(mainAppModel: mainAppModel, reportsViewModel: reportsViewModel, reportId: reportId)

        initVaultFile(reportId: reportId)
        
        initializeProgressionInfos()
        
        if shouldStartUpload {
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
    
    override func updateProgressInfos(uploadProgressInfo : UploadProgressInfo) {
        
        _ = self.reportViewModel.files.compactMap { _ in
            let currentFile = self.reportViewModel.files.first(where: {$0.id == uploadProgressInfo.fileId})
            currentFile?.current = uploadProgressInfo.current ?? 0
            return currentFile
        }
        
        guard  let _ = self.reportViewModel.files.first(where: {$0.id == uploadProgressInfo.fileId}) else { return}
        
        // All Files
        let totalBytesSent = self.reportViewModel.files.reduce(0) { $0 + ($1.bytesSent)}
        let totalSize = self.reportViewModel.files.reduce(0) { $0 + ($1.size)}
        
        // current file
        
        if let currentFileTotalBytesSent = uploadProgressInfo.total {
            
            if totalSize > 0 {
                
                // All Files
                let percentUploaded = Float(totalBytesSent) / Float(totalSize)
                let formattedPercentUploaded = percentUploaded >= 1.0 ? 1.0 : Float(percentUploaded)
                let formattedTotalUploaded = totalBytesSent.getFormattedFileSize().getFileSizeWithoutUnit()
                let formattedTotalSize = totalSize.getFormattedFileSize()
                
                DispatchQueue.main.async {
                    // Progress Files
                    self.percentUploadedInfo = "\(Int(formattedPercentUploaded * 100))% uploaded"
                    self.percentUploaded = Float(formattedPercentUploaded)
                    self.uploadedFiles = " \(self.reportViewModel.files.count) files, \(formattedTotalUploaded)/\(formattedTotalSize) uploaded"
                    
                    //Progress File Item
                    if let currentItem = self.progressFileItems.first(where: {$0.file.id == uploadProgressInfo.fileId}) {
                        
                        let size = currentItem.file.size.getFormattedFileSize()
                        let currentFileTotalBytesSent = currentFileTotalBytesSent.getFormattedFileSize().getFileSizeWithoutUnit()
                        
                        currentItem.progression = "\(currentFileTotalBytesSent)/\(size )"
                    }
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    // MARK: Update Local database
    
    override func updateReportStatus(reportStatus:ReportStatus) {
        
        self.reportViewModel.status = reportStatus
        
        guard let id = reportViewModel.id else { return  }

        mainAppModel.tellaData?.updateReportStatus(idReport: id, status: reportStatus)
    }
    
    override func deleteReport() {
        mainAppModel.deleteReport(reportId: reportViewModel.id)
        mainAppModel.deleteReport(reportId: reportViewModel.id)
    }
}
