//
//  OutboxMainViewModel.swift
//  Tella
//
//  Created by gus valbuena on 7/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class OutboxMainViewModel<T: Server>: ObservableObject {
    
    var mainAppModel : MainAppModel
    @Published var reportsViewModel: ReportsMainViewModel
    
    @Published var reportViewModel : ReportViewModel = ReportViewModel<T>()
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
    
    @Published var shouldShowToast : Bool = false
    @Published var toastMessage : String = ""
    
    @Published var shouldShowLoginView : Bool = false
    
    var subscribers = Set<AnyCancellable>()
    var filesToUpload : [FileToUpload] = []
    
    var uploadButtonTitle: String {
        
        switch reportViewModel.status {
        case .finalized:
            return LocalizableReport.submitOutbox.localized
        case .submissionInProgress:
            return LocalizableReport.pauseOutbox.localized
        default:
            return LocalizableReport.resumeOutbox.localized
        }
    }
    
    var reportHasFile: Bool {
        return !reportViewModel.files.isEmpty
    }
    
    var reportHasDescription: Bool {
        return !reportViewModel.description.isEmpty
    }
    
    var shouldShowCancelUploadConfirmation : Bool {
        return false
    }
    
    init(reportsViewModel: ReportsMainViewModel, reportId : Int?) {
        self.mainAppModel = reportsViewModel.mainAppModel
        self.reportsViewModel = reportsViewModel
        
        initVaultFile(reportId: reportId)
        
        initializeProgressionInfos()
        
    }
    
    func initVaultFile(reportId: Int?) {}
    
    func initSubmission() {
        reportViewModel.status == .submissionScheduled ? self.submitReport() : self.pauseSubmission()
    }
    
    func processVaultFiles(reportFiles: [ReportFile]?) -> [ReportVaultFile] {
        
        var files: [ReportVaultFile] = []
        let fileIds = reportFiles?.compactMap(\.fileId) ?? []
        let vaultFileResult  = mainAppModel.vaultFilesManager?.getVaultFiles(ids: fileIds)
        
        reportFiles?.forEach({ reportFile in
            guard
                let vaultFile = vaultFileResult?.first(where: {reportFile.fileId == $0.id})
            else {
                return
            }
            let reportVaultFile = ReportVaultFile(reportFile: reportFile, vaultFile: vaultFile)
            files.append(reportVaultFile)
        })
        return files
    }
    
    func initializeProgressionInfos() {
        
        let totalSize = self.reportViewModel.files.reduce(0) { $0 + ($1.size) }
        let bytesSent = self.reportViewModel.files.reduce(0) { $0 + ($1.bytesSent)}
        
        if totalSize > 0 {
            
            // All Files
            let percentUploaded = Float(bytesSent) / Float(totalSize)
            
            let formattedPercentUploaded = percentUploaded >= 1.0 ? 1.0 : Float(percentUploaded)
            
            let formattedTotalUploaded = bytesSent.getFormattedFileSize().getFileSizeWithoutUnit()
            let formattedTotalSize = totalSize.getFormattedFileSize()
            
            self.percentUploadedInfo = "\(Int(formattedPercentUploaded * 100))% \(LocalizableReport.reportUploaded.localized)"
            self.percentUploaded = Float(percentUploaded)
            let filesCount = "\(self.reportViewModel.files.count) \(self.reportViewModel.files.count == 1 ? LocalizableReport.reportFile.localized : LocalizableReport.reportFiles.localized)"
            let fileUploaded = "\(formattedTotalUploaded)/\(formattedTotalSize) \(LocalizableReport.reportUploaded.localized)"
            
            self.uploadedFiles = "\(filesCount), \(fileUploaded)"
            
            self.progressFileItems = self.reportViewModel.files.compactMap{ProgressFileItemViewModel(file: $0, progression: ($0.bytesSent.getFormattedFileSize()) + "/" + ($0.size.getFormattedFileSize()))}
            
            self.objectWillChange.send()
        }
    }
    
    func pauseSubmission() {}
    
    func submitReport() {}
    
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
    
    func updateCurrentFile(uploadProgressInfo : UploadProgressInfo) {
        
        self.reportViewModel.files = self.reportViewModel.files.compactMap { file in
            guard file.id == uploadProgressInfo.fileId else { return file }
            
            let updatedFile = file
            if let bytesSent = uploadProgressInfo.bytesSent {
                updatedFile.bytesSent = bytesSent
            }
            updatedFile.status = uploadProgressInfo.status
            updatedFile.sessionId = uploadProgressInfo.sessionId
            updatedFile.finishUploading = uploadProgressInfo.finishUploading
            
            return updatedFile
        }
        
        let filesAreNotfinishUploading = reportViewModel.files.filter({$0.finishUploading == false})
        if uploadProgressInfo.status == .submissionError && filesAreNotfinishUploading.isEmpty {
            reportViewModel.status = .submissionError
            publishUpdates()
        }
    }
    
    func checkAllFilesAreUploaded() {
        
        let filesAreNotfinishUploading = reportViewModel.files.filter({$0.finishUploading == false})
        let filesAreNotSubmitted = reportViewModel.files.filter({$0.status != .uploaded})
        if (filesAreNotfinishUploading.isEmpty) && (filesAreNotSubmitted.isEmpty) {
            
            updateReport(reportStatus: .submitted)
            showSubmittedReport()
            deleteFilesAfterSubmission()
        }
        
        let submissionErrorFiles = reportViewModel.files.filter({$0.status == .submissionError})
        
        if !(submissionErrorFiles.isEmpty) && filesAreNotfinishUploading.isEmpty {
            reportViewModel.status = .submissionError
            publishUpdates()
        }
    }
    
    func updateProgressInfos(uploadProgressInfo : UploadProgressInfo) {
        
        updateCurrentFile(uploadProgressInfo: uploadProgressInfo)
        
        guard  let file = self.reportViewModel.files.first(where: {$0.id == uploadProgressInfo.fileId}) else { return}
        
        self.updateFile(file: file)
        
        // All Files
        let totalBytesSent = self.reportViewModel.files.reduce(0) { $0 + ($1.bytesSent)}
        let totalSize = self.reportViewModel.files.reduce(0) { $0 + ($1.size)}
        
        // current file
        
        guard  let currentFileTotalBytesSent = uploadProgressInfo.bytesSent else {return}
        
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
            }
            //Progress File Item
            if let currentItem = self.progressFileItems.first(where: {$0.file.id == uploadProgressInfo.fileId}) {
                
                let size = currentItem.file.size.getFormattedFileSize()
                let currentFileTotalBytesSent = currentFileTotalBytesSent.getFormattedFileSize().getFileSizeWithoutUnit()
                
                currentItem.progression = "\(currentFileTotalBytesSent)/\(size )"
            }
            publishUpdates()
        }
    }
    
    func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func handleDeleteReport(deleteResult:Result<Void,Error>) {
        
        switch deleteResult {
        case .success:
            toastMessage = String(format: LocalizableReport.reportDeletedToast.localized, reportViewModel.title)
            pauseSubmission()
            showMainView()
        case .failure(let error):
            toastMessage = error.localizedDescription
        }
        shouldShowToast = true
    }
    
    func updateReport(reportStatus: ReportStatus? = nil,
                      remoteReportStatus: RemoteReportStatus? = nil ,
                      newFileName: String? = nil) {
    }
    
    func deleteFilesAfterSubmission() {
    }
    
    // MARK: Update Local database
    
    func updateFile(file: ReportVaultFile) { }
    
    func updateReportStatus(reportStatus:ReportStatus) {}
    
    func updateReport() {}
    
    func deleteReport() {}
}
