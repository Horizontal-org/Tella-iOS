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
        dropboxRepository.createFolder(name: reportViewModel.title, description: reportViewModel.description)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self]completion in
                switch completion {
                case .finished:
                    debugLog("Folder created successfully")
                case .failure(let error):
                    switch error {
                    case .noToken:
                        self?.updateReportStatus(reportStatus: .submissionError)
                        self?.shouldShowLoginView = true
                    default:
                        debugLog("Error creating folder: \(error)")
                        self?.updateReportStatus(reportStatus: .submissionError)
                        self?.toastMessage = error.errorMessage
                        self?.shouldShowToast = true
                    }
                    
                }
            }, receiveValue: { folderId in
                self.reportViewModel.folderId = folderId
                self.updateReportFolderId(folderId: folderId)
                self.uploadFiles(to: "/\(self.reportViewModel.title)")
            })
            .store(in: &cancellables)
    }
        
    private func uploadFiles(to folderPath: String) {
        let files = reportViewModel.files.filter { $0.status != .uploaded }
        let filesToSend: [DropboxFileInfo] = files.compactMap { file -> DropboxFileInfo? in
            guard let url = self.mainAppModel.vaultManager.loadVaultFileToURL(file: file, withSubFolder: true) else {
                return nil
            }

            return DropboxFileInfo(url: url,
                                   fileName: url.lastPathComponent,
                                   fileId: file.id ?? "",
                                   offset: file.offset ?? 0,
                                   sessionId: file.sessionId)
        }

        dropboxRepository.uploadReport(folderPath: folderPath, files: filesToSend)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.updateReportStatus(reportStatus: .submitted)
                    self?.showSubmittedReport()
                case .failure(let error):
                    debugLog(error)
                    switch error {
                    case .noToken:
                        self?.updateReportStatus(reportStatus: .submissionError)
                        self?.shouldShowLoginView = true
                    default:
                        self?.updateReportStatus(reportStatus: .submissionError)
                        self?.toastMessage = error.errorMessage
                        self?.shouldShowToast = true
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
    
    override func updateCurrentFile(uploadProgressInfo: UploadProgressInfo) {
        guard let dropboxProgressInfo = uploadProgressInfo as? DropboxUploadProgressInfo else {
            return
        }
        
        // Update the file's bytesSent and status
        self.reportViewModel.files = self.reportViewModel.files.compactMap { file in
            guard file.id == dropboxProgressInfo.fileId else { return file }
            let updatedFile = file
            updatedFile.bytesSent = dropboxProgressInfo.bytesSent ?? 0
            updatedFile.status = dropboxProgressInfo.status
            return updatedFile
        }
        
        // Update the file in the database with offset and sessionId
        if let file = self.reportViewModel.files.first(where: { $0.id == dropboxProgressInfo.fileId }) {
            let dropboxFile = file
            
            dropboxFile.sessionId = dropboxProgressInfo.sessionId
            dropboxFile.offset = dropboxProgressInfo.offset
            
            self.updateFile(file: dropboxFile)
        }
    }
    
    private func updateReportFolderId(folderId: String) {
        guard let id = reportViewModel.id else { return }
        
        mainAppModel.tellaData?.updateDropboxFolderId(reportId: id, folderId: folderId)
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
            self.submitReport()
        }
    }
    
}

struct DropboxFileInfo {
    let url: URL
    let fileName: String
    let fileId: String
    let offset: Int64?
    let sessionId: String?
}
