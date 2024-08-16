//
//  OutboxMainViewModel.swift
//  Tella
//
//  Created by gus valbuena on 7/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class OutboxMainViewModel<T: ServerProtocol>: ObservableObject {
    
    var mainAppModel : MainAppModel
    var reportsViewModel : ReportsMainViewModel
    
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
    
    var shouldShowCancelUploadConfirmation : Bool {
        return false
    }

    init(mainAppModel: MainAppModel, reportsViewModel : ReportsMainViewModel, reportId : Int?) {
        self.mainAppModel = mainAppModel
        self.reportsViewModel = reportsViewModel
        
        initVaultFile(reportId: reportId)
        
        initializeProgressionInfos()

    }
    
    func initVaultFile(reportId: Int?) {}
    
    func initializeProgressionInfos() {
        
        let totalSize = self.reportViewModel.files.reduce(0) { $0 + ($1.size) }
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
                
                self.progressFileItems = self.reportViewModel.files.compactMap{ProgressFileItemViewModel(file: $0, progression: ($0.bytesSent.getFormattedFileSize()) + "/" + ($0.size.getFormattedFileSize()))}
                
                self.objectWillChange.send()
                
            }
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
    
    func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func handleDeleteReport(deleteResult:Bool) {
        if deleteResult {
            toastMessage = String(format: LocalizableReport.reportDeletedToast.localized, reportViewModel.title)
            pauseSubmission()
            showMainView()
        } else {
            toastMessage = LocalizableCommon.commonError.localized
        }

        shouldShowToast = true
    }

    // MARK: Update Local database
    
    func updateFile(file: ReportVaultFile) { }
    
    func updateReportStatus(reportStatus:ReportStatus) {}
    
    func updateReport() {}

    func deleteReport() {}
}