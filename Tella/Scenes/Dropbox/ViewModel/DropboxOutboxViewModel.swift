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
    private var currentReport : DropboxReport?
    
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
            
            currentReport = report
            
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
    
    override func pauseSubmission() {
        if isSubmissionInProgress {
            dropboxRepository.pauseUpload()
            updateReport(reportStatus: .submissionPaused)
        }
    }
    
    override func updateReport() {
        guard let currentReport else {return}
        _ = mainAppModel.tellaData?.updateDropboxReportWithoutFiles(report: currentReport)
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
    
    override func updateFile(file: ReportVaultFile) {
        guard let dropboxFile = DropboxReportFile(reportFile: file) else { return }
        
        mainAppModel.tellaData?.updateDropboxReportFile(file: dropboxFile)
    }
    
    private func performSubmission() {
        if isSubmissionInProgress { return }
        
        self.updateReport(reportStatus: .submissionInProgress)
        cancellables.removeAll()
        
        let reportToSend = DropboxReportToSend(folderId: reportViewModel.folderId,
                                               name: reportViewModel.title,
                                               description: reportViewModel.description,
                                               files: parseDropboxFiles(),
                                               remoteReportStatus: reportViewModel.remoteReportStatus ?? .unknown)
        
        dropboxRepository.submitReport(report: reportToSend)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                
                self.handleSubmitReportCompletion(completion:completion)
                
            }, receiveValue: { response in
                
                self.processUploadReportResponse(response:response)
            })
            .store(in: &cancellables)
    }
    
    private func handleSubmitReportCompletion(completion:Subscribers.Completion<APIError>) {
        switch completion {
        case .finished:
            self.checkAllFilesAreUploaded()
        case .failure(let error):
            switch error {
            case .noToken:
                self.updateReport(reportStatus: .submissionError)
                self.shouldShowLoginView = true
            default:
                self.updateReport(reportStatus: .submissionError)
                self.toastMessage = error.errorMessage
                self.shouldShowToast = true
            }
        }
    }
    
    private func processUploadReportResponse(response:DropboxUploadResponse) {
        switch response {
            
        case .initial:
            debugLog("Starting dropbox upload process")
            
        case .folderCreated(let folderName):
            self.updateReport(remoteReportStatus: .created, newFileName: folderName)
            
        case .descriptionSent:
            self.updateReport(remoteReportStatus: .descriptionSent)
            
        case .progress(let progressInfo):
            self.updateProgressInfos(uploadProgressInfo: progressInfo)
            self.checkAllFilesAreUploaded()
        }
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
                                   sessionId: file.sessionId,
                                   totalBytes: Int64(file.size))
        }
        
        return filesToSend
    }
    
    private func updateReportFolderId(name: String) {
        guard let id = reportViewModel.id else { return }
        
        mainAppModel.tellaData?.updateDropboxFolderId(reportId: id, folderName: name )
    }
    
    private func checkAllFilesAreUploaded() {
        let filesAreNotSubmitted = reportViewModel.files.filter({$0.status != .uploaded})
        if (filesAreNotSubmitted.isEmpty) {
            updateReport(reportStatus: .submitted)
            showSubmittedReport()
        }
    }
    
    private func updateReport(reportStatus: ReportStatus? = nil, remoteReportStatus: RemoteReportStatus? = nil , newFileName: String? = nil) {
        
        if let reportStatus {
            self.reportViewModel.status = reportStatus
            self.currentReport?.status = reportStatus
        }
        
        if let remoteReportStatus {
            self.reportViewModel.remoteReportStatus = remoteReportStatus
            self.currentReport?.remoteReportStatus = remoteReportStatus
        }
        
        if let newFileName {
            self.reportViewModel.title = newFileName
            self.currentReport?.title = newFileName
        }
        
        updateReport()
        publishUpdates()
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
