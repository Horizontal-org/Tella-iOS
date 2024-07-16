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
        guard let folderId = reportViewModel.folderId else {
            return performSubmission()
        }
        
        let _ = self.uploadFiles(to: folderId)
    }
    
    func performSubmission() {
        gDriveRepository.createDriveFolder(
            folderName: reportViewModel.title,
            parentId: reportViewModel.server?.rootFolder,
            description: reportViewModel.description
        )
        .receive(on: DispatchQueue.main)
        .flatMap { folderId -> AnyPublisher<UploadProgressWithFolderId, Error> in
            self.reportViewModel.folderId = folderId
            self.updateReportFolderId(folderId: folderId)
            return self.uploadFiles(to: folderId)
        }
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.updateReportStatus(reportStatus: .submitted)
                    self.showSubmittedReport()
                    break
                case .failure(let error):
                    debugLog(error)
                }
            },
            receiveValue: { uploadProgressWithFolderId in
                self.updateProgressInfos(uploadProgressInfo: uploadProgressWithFolderId.progressInfo)
            }
        ).store(in: &subscribers)
    }
    
    private func uploadFiles(to folderId: String) -> AnyPublisher<UploadProgressWithFolderId, Error> {
        let uploadPublishers = reportViewModel.files.map { file -> AnyPublisher<UploadProgressWithFolderId, Error> in
            guard let fileUrl = self.mainAppModel.vaultManager.loadVaultFileToURL(file: file) else {
                return Fail(error: APIError.unexpectedResponse).eraseToAnyPublisher()
            }
            
            return gDriveRepository.uploadFile(fileURL: fileUrl, fileId: file.id ?? "", mimeType: file.mimeType ?? "", folderId: folderId)
                .map { progressInfo in
                    UploadProgressWithFolderId(folderId: folderId, progressInfo: progressInfo)
                }
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(uploadPublishers)
            .eraseToAnyPublisher()
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
