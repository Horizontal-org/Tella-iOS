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
            
            let vaultFileResult  = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report.reportFiles?.compactMap{$0.fileId} ?? [])
            
            var files: [ReportVaultFile] = []
            
            report.reportFiles?.forEach({ reportFile in
                guard let vaultFile = vaultFileResult?.first(where: {reportFile.fileId == $0.id}),
                      let dropboxReportFile = reportFile as? DropboxReportFile else { return}
                let reportVaultFile = ReportVaultFile(reportFile: dropboxReportFile, vaultFile: vaultFile)
                files.append(reportVaultFile)
            })
            
            self.reportViewModel = ReportViewModel(report: report, files: files)
            
        }
    }

    override func submitReport() {
        performSubmission()
    }
    
    private func performSubmission() {
        if isSubmissionInProgress { return }

        self.updateReportStatus(reportStatus: .submissionInProgress)
        cancellables.removeAll()
        
        let reportToSend = DropboxReportToSend(folderId: reportViewModel.folderId, name: reportViewModel.title, description: reportViewModel.description, files: parseDropboxFiles())
        
        dropboxRepository.submitReport(reportToSend: reportToSend)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                self.checkAllFilesAreUploaded()
            case .failure(let error):
                switch error {
                case .noToken:
                    self.updateReportStatus(reportStatus: .submissionError)
                    self.shouldShowLoginView = true
                default:
                    self.updateReportStatus(reportStatus: .submissionError)
                    self.toastMessage = error.errorMessage
                    self.shouldShowToast = true
                }
            }
            
        }, receiveValue: { response in
            switch response {
            case .initial:
                debugLog("startin dropbox upload process")
            case .folderCreated(let folderId, let folderName):
                self.reportViewModel.folderId = folderId
                self.reportViewModel.title = folderName
                self.updateReportFolderId(folderId: folderId, name: folderName)
            case .progress(let progressInfo):
                self.updateProgressInfos(uploadProgressInfo: progressInfo)
            case .finished:
                self.checkAllFilesAreUploaded()
                
            }
        })
        .store(in: &cancellables)
    }
    
    private func parseDropboxFiles() -> [DropboxFileInfo]{
        let files = reportViewModel.files.filter { $0.status != .uploaded }
        let filesToSend: [DropboxFileInfo] = files.compactMap { file -> DropboxFileInfo? in
            guard let url = self.mainAppModel.vaultManager.loadVaultFileToURL(file: file, withSubFolder: true) else {
                return nil
            }

            return DropboxFileInfo(url: url,
                                   fileName: url.lastPathComponent,
                                   fileId: file.id ?? "",
                                   offset: Int64(file.bytesSent),
                                   sessionId: file.sessionId)
        }
        
        return filesToSend
    }

    override func pauseSubmission() {
        if isSubmissionInProgress {
            dropboxRepository.pauseUpload()
            updateReportStatus(reportStatus: .submissionPaused)
            
            cancellables.removeAll()
        }
    }
    
    private func checkAllFilesAreUploaded() {
        let filesAreNotSubmitted = reportViewModel.files.filter({$0.status != .uploaded})
        if (filesAreNotSubmitted.isEmpty) {
            updateReportStatus(reportStatus: .submitted)
            showSubmittedReport()
        }
    }
    
    override func updateReportStatus(reportStatus: ReportStatus) {
        self.reportViewModel.status = reportStatus
        self.objectWillChange.send()
        
        guard let id = reportViewModel.id else { return }
        
        mainAppModel.tellaData?.updateDropboxReportStatus(reportId: id, status: reportStatus)
    }
    
    override func updateCurrentFile(uploadProgressInfo: UploadProgressInfo) {
        guard let dropboxProgressInfo = uploadProgressInfo as? DropboxUploadProgressInfo else {
            return
        }
        
        self.reportViewModel.files = self.reportViewModel.files.compactMap { file in
            guard file.id == dropboxProgressInfo.fileId else { return file }
            let updatedFile = file
            updatedFile.bytesSent = dropboxProgressInfo.bytesSent ?? 0
            updatedFile.status = dropboxProgressInfo.status
            return updatedFile
        }
        
        if let file = self.reportViewModel.files.first(where: { $0.id == dropboxProgressInfo.fileId }) {
            let dropboxFile = file
            
            dropboxFile.sessionId = dropboxProgressInfo.sessionId
            dropboxFile.bytesSent = dropboxProgressInfo.bytesSent ?? 0
            
            self.updateFile(file: dropboxFile)
        }
    }
    
    private func updateReportFolderId(folderId: String, name: String) {
        guard let id = reportViewModel.id else { return }
        
        mainAppModel.tellaData?.updateDropboxFolderId(reportId: id, folderId: folderId,folderName: name )
    }
    
    override func updateFile(file: ReportVaultFile) {
        guard let dropboxFile = DropboxReportFile(reportFile: file) else { return }
        
        mainAppModel.tellaData?.updateDropboxReportFile(file: dropboxFile)
    }
    
    func reAuthenticateConnection() {
        Task {
            do {
                try await dropboxRepository.handleSignIn()
            } catch {
                debugLog(error)
            }
        }
    }
    
    func handleURLRedirect(url: URL) {
        _ = dropboxRepository.handleRedirectURL(url) { authResult in
            switch authResult {
            case .success:
                self.submitReport()
            case .error(_, let description):
                self.shouldShowToast = true
                self.toastMessage = description ?? ""
            default:
                break
            }
        }
    }
    
}
