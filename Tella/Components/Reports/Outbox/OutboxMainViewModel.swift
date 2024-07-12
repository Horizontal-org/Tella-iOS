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
    var reportsViewModel : ReportMainViewModel
    
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
    
    
    init(mainAppModel: MainAppModel, reportsViewModel : ReportMainViewModel, reportId : Int?, shouldStartUpload: Bool = false) {
        self.mainAppModel = mainAppModel
        self.reportsViewModel = reportsViewModel
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
    
    func updateProgressInfos(uploadProgressInfo : UploadProgressInfo) {}
    
    // MARK: Update Local database
    
    func updateReportStatus(reportStatus:ReportStatus) {}
    
    func deleteReport() {}
}