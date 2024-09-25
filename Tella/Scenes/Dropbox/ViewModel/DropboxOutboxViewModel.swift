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
        cancellables.removeAll()
        
        if reportViewModel.folderId != nil {
            uploadFiles(to: "/\(reportViewModel.title)")
        } else {
            createDropboxFolder()
        }
    }
    
    private func createDropboxFolder() {
        Task {
            do {
                let folderId = try await dropboxRepository.createFolder(
                    name: reportViewModel.title,
                    description: reportViewModel.description
                )
                await MainActor.run {
                    self.reportViewModel.folderId = folderId
                    self.updateReportFolderId(folderId: folderId)
                    self.uploadFiles(to: "/\(self.reportViewModel.title)")
                }
            } catch {
                await MainActor.run {
                    self.updateReportStatus(reportStatus: .submissionError)
                    debugLog("Error creating folder: \(error)")
                }
            }
        }
    }
        
    private func uploadFiles(to folderPath: String) {
        let files = reportViewModel.files.filter { $0.status != .submitted }
        let filesToSend = files.compactMap { file -> (URL, String, String)? in
            guard let url = self.mainAppModel.vaultManager.loadVaultFileToURL(file: file, withSubFolder: true) else {
                return nil
            }
            let fileId = file.id ?? ""
            let fileName = url.lastPathComponent
            return (url, fileName, fileId)
        }
        
        dropboxRepository.uploadReport(folderPath: folderPath, files: filesToSend)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.updateReportStatus(reportStatus: .submitted)
                    self?.showSubmittedReport()
                case .failure(let error):
                    if (error as NSError).code == 1 {
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
            
            cancellables.removeAll()
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
    
    private func updateReportFolderId(folderId: String) {
        guard let id = reportViewModel.id else { return }
        
        mainAppModel.tellaData?.updateDropboxFolderId(reportId: id, folderId: folderId)
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
