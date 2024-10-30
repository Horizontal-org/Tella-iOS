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
        
        self.initSubmission()
    }
    
    override func initVaultFile(reportId: Int?) {
        
        guard
            let reportId,
            let report = self.mainAppModel.tellaData?.getDropboxReport(id: reportId)
        else {
            return
        }
        
        currentReport = report
        let files = processVaultFiles(reportFiles: report.reportFiles)
        self.reportViewModel = ReportViewModel(report: report, files: files)
    }
    
    override func submitReport() {
        
        if isSubmissionInProgress { return }
        self.updateReport(reportStatus: .submissionInProgress)
        cancellables.removeAll()
        
        Task {
            
            let reportToSend = await DropboxReportToSend(folderId: reportViewModel.folderId,
                                                         name: reportViewModel.title,
                                                         description: reportViewModel.description,
                                                         files: prepareDropboxFilesToSend(),
                                                         remoteReportStatus: reportViewModel.remoteReportStatus ?? .initial)
            
            dropboxRepository.submit(report: reportToSend)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    
                    self.handleSubmitReportCompletion(completion:completion)
                    
                }, receiveValue: { response in
                    
                    self.processUploadReportResponse(response:response)
                })
                .store(in: &cancellables)
        }
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
    
    override func updateFile(file: ReportVaultFile) {
        guard let dropboxFile = DropboxReportFile(reportFile: file) else { return }
        mainAppModel.tellaData?.updateDropboxReportFile(file: dropboxFile)
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
    
    private func prepareDropboxFilesToSend() async -> [DropboxFileInfo] {
        
        let files = reportViewModel.files.filter { $0.status != .uploaded }
        var dropboxFiles: [DropboxFileInfo] = []
        
        for file in files {
            if let url = await self.mainAppModel.vaultManager.loadVaultFileToURLAsync(file: file, withSubFolder: true) {
                let dropboxFile = DropboxFileInfo(url: url,
                                                  fileName: url.lastPathComponent,
                                                  fileId: file.id ?? "",
                                                  offset: Int64(file.bytesSent),
                                                  sessionId: file.sessionId,
                                                  totalBytes: Int64(file.size))
                dropboxFiles.append(dropboxFile)
            }
        }
        return dropboxFiles
    }
    
    private func updateReportFolderId(name: String) {
        guard let id = reportViewModel.id else { return }
        
        mainAppModel.tellaData?.updateDropboxFolderId(reportId: id, folderName: name )
    }
    
    override func updateReport(reportStatus: ReportStatus? = nil, remoteReportStatus: RemoteReportStatus? = nil , newFileName: String? = nil) {
        
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
