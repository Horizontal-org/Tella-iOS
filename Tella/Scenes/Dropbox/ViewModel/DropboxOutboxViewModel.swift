//
//  DropboxOutboxViewModel.swift
//  Tella
//
//  Created by gus valbuena on 9/19/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class DropboxOutboxViewModel: OutboxMainViewModel<DropboxServer> {
    let dropboxRepository: DropboxRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    override var shouldShowCancelUploadConfirmation: Bool {
        return true
    }
    
    init(reportsViewModel: ReportsMainViewModel,
                  reportId: Int?,
                  repository: DropboxRepositoryProtocol) {
        self.dropboxRepository = repository
        super.init(reportsViewModel: reportsViewModel, reportId: reportId)

        if reportViewModel.status == .submissionScheduled {
            self.submitReport()
        } else {
            self.pauseSubmission()
        }
    }
    
    override func initVaultFile(reportId: Int?) {
        if let reportId, let report = self.mainAppModel.tellaData?.getDropboxReport(id: reportId) {
            let files = processVaultFiles(reportFiles: report.reportFiles)
            
            self.reportViewModel = ReportViewModel(report: report, files: files)
        }
    }
    
    override func submitReport() {
        if isSubmissionInProgress { return }
        
        self.updateReportStatus(reportStatus: .submissionInProgress)
        performSubmission()
    }
    
    private func performSubmission() {
        let files = reportViewModel.files.filter { $0.status != .submitted }
        let filesToSend = files.compactMap { file -> (URL, String, String)? in
            guard let url = self.mainAppModel.vaultManager.loadVaultFileToURL(file: file, withSubFolder: true) else {
                return nil
            }
            let fileId = file.id ?? ""
            let fileName = url.lastPathComponent
            return (url, fileName, fileId)
        }
        
        let uploadPublisher: AnyPublisher<UploadProgressInfo, Error>
        if reportViewModel.status == .submissionPaused {
            uploadPublisher = dropboxRepository.resumeUpload()
        } else {
            uploadPublisher = dropboxRepository.uploadReport(title: reportViewModel.title, description: reportViewModel.description, files: filesToSend)
        }
        
        uploadPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.updateReportStatus(reportStatus: .submitted)
                    self?.showSubmittedReport()
                case .failure(let error):
                    if (error as NSError).code == 1 { // Upload paused
                        self?.updateReportStatus(reportStatus: .submissionPaused)
                    } else {
                        self?.updateReportStatus(reportStatus: .submissionError)
                        debugLog("Error uploading report: \(error)")
                    }
                }
            }, receiveValue: { [weak self] progressInfo in
                self?.updateProgressInfos(uploadProgressInfo: progressInfo)
            })
            .store(in: &cancellables)
    }
    
    override func pauseSubmission() {
        if isSubmissionInProgress {
            dropboxRepository.pauseUpload()
            updateReportStatus(reportStatus: .submissionPaused)
        }
    }
    
    override func updateReportStatus(reportStatus: ReportStatus) {
        self.reportViewModel.status = reportStatus
        self.objectWillChange.send()
        
        guard let id = reportViewModel.id else { return }
        
        mainAppModel.tellaData?.updateDropboxReportStatus(reportId: id, status: reportStatus)
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
    
    override func updateFile(file: ReportVaultFile) {
        guard let reportId = reportViewModel.id else { return }
        
        let reportFiles = reportViewModel.files.map { file in
            return ReportFile(
                file: file,
                reportInstanceId: reportViewModel.id
            )
        }
        
        let _ = mainAppModel.tellaData?.updateDropboxFiles(reportId: reportId, files: reportFiles)
    }
}
