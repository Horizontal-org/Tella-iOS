//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine

class OutboxReportVM: ObservableObject {
    
    var mainAppModel : MainAppModel
    var reportsViewModel : ReportsViewModel
    
    @Published var reportViewModel : ReportViewModel = ReportViewModel()
    @Published var progressFileItems : [ProgressFileItemViewModel] = []
    @Published var percentUploaded : Float = 0.0
    @Published var percentUploadedInfo : String = LocalizableReport.waitingConnection.localized
    @Published var uploadedFiles : String = ""
    
    @Published var isLoading : Bool = false
    var isSubmissionInProgress: Bool {
        return reportViewModel.status == .submissionInProgress
        
    }
    @Published var shouldShowSubmittedReportView : Bool = false
    @Published var shouldShowMainView : Bool = false
    
    private var subscribers = Set<AnyCancellable>()
    private var filesToUpload : [FileToUpload] = []
    private var reportRepository = ReportRepository()
    
    var uploadButtonTitle: String {
        
        switch reportViewModel.status {
        case .finalized:
            return "Submit"
        case .submissionInProgress:
            return "Pause"
        default:
            return "Resume"
        }
    }
    
    var reportHasFile: Bool {
        return !reportViewModel.files.isEmpty
    }
    
    var reportHasDescription: Bool {
        return !reportViewModel.description.isEmpty
    }
    
    var reportIsNotAutoDelete: Bool {
        return !(reportViewModel.server?.autoDelete ?? true)
    }
    
    
    init(mainAppModel: MainAppModel, reportsViewModel : ReportsViewModel, reportId : Int?, shouldStartUpload: Bool = false) {
        
        self.mainAppModel = mainAppModel
        self.reportsViewModel = reportsViewModel
        
        initVaultFile(reportId: reportId)
        
        initializeProgressionInfos()
        
        if shouldStartUpload {
            self.submitReport()
        } else {
            treat(uploadResponse:reportRepository.checkUploadReportOperation(reportId: self.reportViewModel.id))
        }
    }
    
    func treat(uploadResponse: CurrentValueSubject<UploadResponse?,APIError>?) {
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
                case .finish(let shouldShowMainView):
                    DispatchQueue.main.async {
                        if shouldShowMainView {
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
    
    func initVaultFile(reportId: Int?) {
        
        if let reportId, let report = self.mainAppModel.vaultManager.tellaData?.getReport(reportId: reportId) {
            
            var vaultFileResult : Set<VaultFile> = []
            
            mainAppModel.vaultManager.root?.getFile(root: mainAppModel.vaultManager.root,
                                                   vaultFileResult: &vaultFileResult,
                                                   ids: report.reportFiles?.compactMap{$0.fileId} ?? [])
            var files : [ReportVaultFile] = []
            
            report.reportFiles?.forEach({ reportFile in
                if let vaultFile = vaultFileResult.first(where: {reportFile.fileId == $0.id}) {
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
    
    func initializeProgressionInfos() {
        
        let totalSize = self.reportViewModel.files.reduce(0) { $0 + $1.size}
        let bytesSent = self.reportViewModel.files.reduce(0) { $0 + ($1.bytesSent)}
        
        if totalSize > 0 {
            
            // All Files
            let percentUploaded = Float(bytesSent) / Float(totalSize)
            
            let formattedPercentUploaded = percentUploaded >= 1.0 ? 1.0 : Float(percentUploaded)
            
            let formattedTotalUploaded = bytesSent.getFormattedFileSize().getFileSizeWithoutUnit()
            let formattedTotalSize = totalSize.getFormattedFileSize()
            DispatchQueue.main.async {
                
                self.percentUploadedInfo = "\(Int(formattedPercentUploaded * 100))% uploaded"
                self.percentUploaded = Float(percentUploaded)
                self.uploadedFiles = " \(self.reportViewModel.files.count) files, \(formattedTotalUploaded)/\(formattedTotalSize) uploaded"
                
                self.progressFileItems = self.reportViewModel.files.compactMap{ProgressFileItemViewModel(file: $0, progression: ($0.bytesSent.getFormattedFileSize()) + "/" + $0.size.getFormattedFileSize())}
                
                self.objectWillChange.send()
                
            }
        }
    }
    
    func pauseSubmission() {
        if isSubmissionInProgress {
            self.updateReportStatus(reportStatus: .submissionPaused)
            self.reportRepository.pause(reportId: self.reportViewModel.id)
            //            self.isSubmissionInProgress = false
        }
        
    }
    
    func submitReport() {
        
        let report = Report(id: reportViewModel.id,
                            title: reportViewModel.title,
                            description: reportViewModel.description,
                            status: reportViewModel.status,
                            server: reportViewModel.server,
                            vaultFiles: self.reportViewModel.reportFiles,
                            
                            apiID: self.reportViewModel.apiID)
        
        if isSubmissionInProgress == false {
            
            //            self.isSubmissionInProgress = true
            self.updateReportStatus(reportStatus: .submissionInProgress)
            
            treat(uploadResponse: self.reportRepository.sendReport(report: report, mainAppModel: mainAppModel))
        }
    }
    
    func showSubmittedReport() {
        DispatchQueue.main.async {
            self.shouldShowSubmittedReportView = true
        }
    }
    
    func showMainView() {
        DispatchQueue.main.async {
            self.shouldShowMainView = true
        }
    }
    
    private func updateProgressInfos(uploadProgressInfo : UploadProgressInfo) {
        
        _ = self.reportViewModel.files.compactMap { _ in
            let currentFile = self.reportViewModel.files.first(where: {$0.id == uploadProgressInfo.fileId})
            currentFile?.current = uploadProgressInfo.current ?? 0
            return currentFile
        }
        
        guard  let currentFile = self.reportViewModel.files.first(where: {$0.id == uploadProgressInfo.fileId}) else { return}
        
        // All Files
        let totalBytesSent = self.reportViewModel.files.reduce(0) { $0 + ($1.bytesSent)}
        let totalSize = self.reportViewModel.files.reduce(0) { $0 + $1.size}
        
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
                        currentItem.progression = "\(currentFileTotalBytesSent.getFormattedFileSize().getFileSizeWithoutUnit())/\(currentItem.file.size.getFormattedFileSize())"
                    }
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    // MARK: Update Local database
    
    func updateReportStatus(reportStatus:ReportStatus) {
        
        self.reportViewModel.status = reportStatus
        
        guard let id = reportViewModel.id else { return  }
        
        do {
            try mainAppModel.vaultManager.tellaData?.updateReportStatus(idReport: id, status: reportStatus)
            
        } catch {
            
        }
    }
    
    func deleteReport() {
        mainAppModel.deleteReport(reportId: reportViewModel.id)
    }
}
