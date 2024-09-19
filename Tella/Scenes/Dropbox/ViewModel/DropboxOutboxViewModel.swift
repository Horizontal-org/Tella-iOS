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
    
    func performSubmission() {
        let files = reportViewModel.files.filter({ $0.status != .submitted })
        let filesToSend = files.compactMap { file -> (URL, String)? in
            guard let url = self.mainAppModel.vaultManager.loadVaultFileToURL(file: file, withSubFolder: true) else {
                return nil
            }
            
            let fileName = url.lastPathComponent
            return (url, fileName)
        }
        
        updateReportStatus(reportStatus: .submissionInProgress)
        
        dropboxRepository.uploadReport(title: reportViewModel.title, description: reportViewModel.description, files: filesToSend)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.updateReportStatus(reportStatus: .submitted)
                    self?.showSubmittedReport()
                case .failure(let error):
                    self?.updateReportStatus(reportStatus: .submissionError)
                    print("Error uploading report: \(error)")
                }
            }, receiveValue: { _ in
                // This is intentionally left empty as we handle the success in the completion handler
            })
            .store(in: &cancellables)
    }
    
    override func pauseSubmission() {
        if isSubmissionInProgress {
            updateReportStatus(reportStatus: .submissionPaused)
        }
    }
    
    override func updateReportStatus(reportStatus: ReportStatus) {
        self.reportViewModel.status = reportStatus
        self.objectWillChange.send()
        
        guard let id = reportViewModel.id else { return }
        
        mainAppModel.tellaData?.updateDropboxReportStatus(reportId: id, status: reportStatus)
    }
}
