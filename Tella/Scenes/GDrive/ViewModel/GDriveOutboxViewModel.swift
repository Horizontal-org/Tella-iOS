//
//  GDriveOutboxViewModel.swift
//  Tella
//
//  Created by gus valbuena on 7/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class GDriveOutboxViewModel: OutboxMainViewModel<GDriveServer> {
    private let gDriveRepository: GDriveRepositoryProtocol
    private var currentUploadCancellable: AnyCancellable?
    private var uploadQueue: [ReportVaultFile] = []
    
    init(mainAppModel: MainAppModel,
         reportsViewModel : ReportMainViewModel,
         reportId : Int?,
         repository: GDriveRepository,
         shouldStartUpload: Bool = false
    ) {
        self.gDriveRepository = repository
        super.init(mainAppModel: mainAppModel, reportsViewModel: reportsViewModel, reportId: reportId)
        
        initVaultFile(reportId: reportId)
        
        initializeProgressionInfos()
        
        if shouldStartUpload {
            self.submitReport()
        }
    }
    
    
    override func initVaultFile(reportId: Int?) {
        if let reportId, let report = self.mainAppModel.tellaData?.getDriveReport(id: reportId) {
            let vaultFileResult  = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report.reportFiles?.compactMap{$0.fileId} ?? [])
            
            var files: [ReportVaultFile] = []
            
            report.reportFiles?.forEach({ reportFile in
                if let vaultFile = vaultFileResult?.first(where: {reportFile.fileId == $0.id}) {
                    let reportVaultFile = ReportVaultFile(reportFile: reportFile, vaultFile: vaultFile)
                    files.append(reportVaultFile)
                }
            })
            
            self.reportViewModel = ReportViewModel(id: report.id,
                                                   title: report.title ?? "",
                                                   description: report.description ?? "",
                                                   files: files,
                                                   reportFiles: report.reportFiles ?? [],
                                                   server: report.server,
                                                   status: report.status,
                                                   apiID: nil,
                                                   folderId: report.folderId)
        }
    }
    
    override func submitReport() {
        if isSubmissionInProgress == false {
            self.updateReportStatus(reportStatus: .submissionInProgress)
        }
        gDriveRepository.resumeAllUploads()
        guard let folderId = reportViewModel.folderId else {
            return performSubmission()
        }
        
        uploadFiles(to: folderId)
    }
    
    func performSubmission() {
        gDriveRepository.createDriveFolder(
            folderName: reportViewModel.title,
            parentId: reportViewModel.server?.rootFolder,
            description: reportViewModel.description
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    debugLog(error)
                    self.updateReportStatus(reportStatus: .submissionError)
                }
            },
            receiveValue: { [weak self] folderId in
                guard let self = self else { return }
                self.reportViewModel.folderId = folderId
                self.updateReportFolderId(folderId: folderId)
                self.uploadFiles(to: folderId)
            }
        ).store(in: &subscribers)
    }
    
    private func uploadFiles(to folderId: String) {
            uploadQueue = reportViewModel.files.filter { $0.status != .uploaded }
            uploadNextFile(folderId: folderId)
        }
        
    private func uploadNextFile(folderId: String) {
        guard let fileToUpload = uploadQueue.first else {
            // All files have been uploaded
            self.updateReportStatus(reportStatus: .submitted)
            self.showSubmittedReport()
            return
        }
        
        guard let fileUrl = self.mainAppModel.vaultManager.loadVaultFileToURL(file: fileToUpload) else {
            // Handle error: unable to load file
            uploadQueue.removeFirst()
            uploadNextFile(folderId: folderId)
            return
        }
        
        currentUploadCancellable = gDriveRepository.uploadFile(fileURL: fileUrl, fileId: fileToUpload.id ?? "", mimeType: fileToUpload.mimeType ?? "", folderId: folderId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .finished:
                        // File upload completed successfully
                        self.uploadQueue.removeFirst()
                        self.uploadNextFile(folderId: folderId)
                    case .failure(let error):
                        debugLog(error)
                        self.updateReportStatus(reportStatus: .submissionError)
                    }
                },
                receiveValue: { [weak self] progressInfo in
                    self?.updateProgressInfos(uploadProgressInfo: progressInfo)
                }
            )
    }
    
    override func updateProgressInfos(uploadProgressInfo: UploadProgressInfo) {
        if let currentFile = self.reportViewModel.files.first(where: { $0.id == uploadProgressInfo.fileId }) {
            currentFile.current = uploadProgressInfo.current ?? 0
            currentFile.bytesSent = uploadProgressInfo.bytesSent ?? 0
            currentFile.status = uploadProgressInfo.status
        }
        
        // All Files
        let totalBytesSent = self.reportViewModel.files.reduce(0) { $0 + ($1.bytesSent) }
        let totalSize = self.reportViewModel.files.reduce(0) { $0 + ($1.size) }
        
        if totalSize > 0 {
            let percentUploaded = Float(totalBytesSent) / Float(totalSize)
            let formattedPercentUploaded = percentUploaded >= 1.0 ? 1.0 : percentUploaded
            let formattedTotalUploaded = totalBytesSent.getFormattedFileSize().getFileSizeWithoutUnit()
            let formattedTotalSize = totalSize.getFormattedFileSize()
            
            DispatchQueue.main.async {
                
                self.percentUploadedInfo = "\(Int(formattedPercentUploaded * 100))% uploaded"
                self.percentUploaded = formattedPercentUploaded
                self.uploadedFiles = " \(self.reportViewModel.files.count) files, \(formattedTotalUploaded)/\(formattedTotalSize) uploaded"
                
                if let currentItem = self.progressFileItems.first(where: { $0.file.id == uploadProgressInfo.fileId }) {
                    let size = currentItem.file.size.getFormattedFileSize()
                    let currentFileTotalBytesSent = uploadProgressInfo.bytesSent?.getFormattedFileSize().getFileSizeWithoutUnit() ?? "0"
                    
                    currentItem.progression = "\(currentFileTotalBytesSent)/\(size)"
                }
                self.objectWillChange.send()
            }
        }
    }
    
    override func pauseSubmission() {
        if isSubmissionInProgress {
            updateReportStatus(reportStatus: .submissionPaused)
            gDriveRepository.pauseAllUploads()
            currentUploadCancellable?.cancel()
            currentUploadCancellable = nil
        }
    }
    
    override func updateReportStatus(reportStatus: ReportStatus) {
        self.reportViewModel.status = reportStatus
        
        guard let id = reportViewModel.id else { return }

        mainAppModel.tellaData?.updateDriveReportStatus(idReport: id, status: reportStatus)
    }
    
    private func updateReportFolderId(folderId: String) {
        guard let id = reportViewModel.id else { return }
        
        mainAppModel.tellaData?.updateDriveFolderId(idReport: id, folderId: folderId)
    }
}
