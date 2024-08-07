//
//  NextcloudOutboxViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 11/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

import Foundation
import Combine

class NextcloudOutboxViewModel: OutboxMainViewModel<NextcloudServer> {
    
    private let nextcloudRepository: NextcloudRepositoryProtocol
    private var currentReport : NextcloudReport?

    override var shouldShowCancelUploadConfirmation : Bool {
        return true
    }

    init(mainAppModel: MainAppModel,
         reportsViewModel : ReportsMainViewModel,
         reportId : Int?,
         repository: NextcloudRepositoryProtocol) {
        
        self.nextcloudRepository = repository
        
        super.init(mainAppModel: mainAppModel, reportsViewModel: reportsViewModel, reportId: reportId)
        
        if reportViewModel.status == .submissionScheduled {
            self.submitReport()
        } else {
            self.updateReport(reportStatus: .submissionPaused)
        }
    }
    
    override func initVaultFile(reportId: Int?) {
        if let reportId, let report = self.mainAppModel.tellaData?.getNextcloudReport(id: reportId) {
            
            currentReport = report
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
                                                   remoteReportStatus: report.remoteReportStatus,
                                                   apiID: nil)
        }
    }
    
    override func submitReport() {
        performSubmission()
    }
    
    func performSubmission() {
        guard
            let currentReport,
            let serverURL = currentReport.server?.url
        else { return }
        
        self.updateReport(reportStatus: .submissionInProgress)
        
        let files = reportViewModel.files.filter({ $0.status != .submitted})
        
        _ = files.compactMap { file in
            file.url = self.mainAppModel.vaultManager.loadVaultFileToURL(file: file, withSubFolder: true)
        }
        
        let remoteFolderName = self.reportViewModel.title.removeForbiddenCharacters()
        
        if reportViewModel.remoteReportStatus != .descriptionSent {
            guard let descriptionFileUrl = self.mainAppModel.vaultManager.getDescriptionFileUrl(content: self.reportViewModel.description,
                                                                                                fileName: NextcloudConstants.descriptionFolderName) else { return  }
            
            reportViewModel.descriptionFileUrl = descriptionFileUrl
        }
        
        let filesToSend = files.compactMap { file in
            let directory = file.url?.directoryPath ?? ""
            let fileName = file.url?.lastPathComponent ?? ""
            let remoteFolderName =  remoteFolderName
            let chunkFiles : [(fileName: String, size: Int64)] = file.chunkFiles ?? []
            let chunkFolder = file.name
            
            return  NextcloudMetadata(fileId: file.id,
                                      directory: directory,
                                      fileName: fileName,
                                      remoteFolderName: remoteFolderName,
                                      serverURL: serverURL,
                                      chunkFolder: chunkFolder,
                                      chunkFiles: chunkFiles)
            
        }
        
        
        let reportToSend = NextcloudReportToSend(folderName: remoteFolderName,
                                                 serverUrl: serverURL,
                                                 descriptionFileUrl: reportViewModel.descriptionFileUrl,
                                                 remoteReportStatus: currentReport.remoteReportStatus ?? .unknown,
                                                 files: filesToSend)
        
        nextcloudRepository.uploadReport(report: reportToSend)
            .sink { completion in
                
                switch completion {
                case .finished:
                    self.checkAllFilesAreUploaded()
                    
                case .failure:
                    self.updateReport(reportStatus: .submissionError)
                }
                
            } receiveValue: { response in
                self.processUploadReportResponse(response:response)
            }.store(in: &subscribers)
    }
    
    private func processUploadReportResponse(response:NextcloudUploadResponse) {
        switch response {
            
        case .createReport:
            self.updateReport(remoteReportStatus: .created)
            
        case .descriptionSent:
            self.updateReport(remoteReportStatus: .descriptionSent)
            deleteDescriptionFile()
            
        case .nameUpdated(let newName):
            self.updateReport(newFileName: newName)
            
        case .progress(let progressInfo):
            
            switch progressInfo.step {
            case .initial:
                break
            case .start:
                self.addChunks(uploadProgressInfo: progressInfo)
            case .progress:
                self.updateProgressInfos(uploadProgressInfo: progressInfo)
            case .chunkSent:
                self.removeChunks(uploadProgressInfo: progressInfo)
            case .finished:
                self.updateCurrentFile(uploadProgressInfo: progressInfo)
                self.checkAllFilesAreUploaded()
            }
        case .initial:
            break
        }
    }
    
    // Check if all the files are submitted
    
    private func checkAllFilesAreUploaded() {
        
        let filesAreNotfinishUploading = reportViewModel.files.filter({$0.finishUploading == false})
        let filesAreNotSubmitted = reportViewModel.files.filter({$0.status != .submitted})
        
        if (filesAreNotfinishUploading.isEmpty) && (filesAreNotSubmitted.isEmpty) {
            updateReport(reportStatus: .submitted)
            showSubmittedReport()
            deleteChunksFiles()
        }
    }
    
    func addChunks(uploadProgressInfo : NextcloudUploadProgressInfo) {
        
        self.reportViewModel.files = self.reportViewModel.files.compactMap { file in
            guard file.id == uploadProgressInfo.fileId else { return file }
            let updatedFile = file
            updatedFile.chunkFiles = uploadProgressInfo.chunkFiles
            return updatedFile
        }
        
        // Find the current file
        guard let currentFile = self.reportViewModel.files.first(where: { $0.id == uploadProgressInfo.fileId }) else { return }
        self.updateFile(file: currentFile)
    }
    
    func removeChunks(uploadProgressInfo : NextcloudUploadProgressInfo) {
        
        guard let chunkSent = uploadProgressInfo.chunkFileSent else { return }
        
        self.reportViewModel.files = self.reportViewModel.files.compactMap { file in
            guard file.id == uploadProgressInfo.fileId else { return file }
            
            let updatedFile = file
            updatedFile.chunkFiles?.removeAll(where: { $0.fileName == chunkSent.fileName })
            
            return updatedFile
        }
        
        // Find the current file
        guard let currentFile = self.reportViewModel.files.first(where: { $0.id == uploadProgressInfo.fileId }) else { return }
        
        // If file URL is found, delete the file
        if let fileURL = currentFile.url?.deletingLastPathComponent().appendingPathComponent(chunkSent.fileName) {
            self.mainAppModel.vaultManager.deleteFiles(files: [fileURL])
        }
        
        // Update the file
        self.updateFile(file: currentFile)
        
    }
    
    override func updateCurrentFile(uploadProgressInfo : UploadProgressInfo) {
        guard let uploadProgressInfo = uploadProgressInfo as? NextcloudUploadProgressInfo else  {
            return
        }
        self.reportViewModel.files = self.reportViewModel.files.compactMap { file in
            guard file.id == uploadProgressInfo.fileId else { return file }
            
            let updatedFile = file
            updatedFile.bytesSent = uploadProgressInfo.bytesSent ?? 0
            updatedFile.status = uploadProgressInfo.status
            updatedFile.finishUploading = uploadProgressInfo.finishUploading
            return updatedFile
        }
    }
    
    override func updateFile(file:ReportVaultFile) {
        guard let file = NextcloudReportFile(reportFile: file) else {return}
        let _ = mainAppModel.tellaData?.updateNextcloudReportFile(reportFile: file)
    }
    
    override func updateReport() {
        guard let currentReport else {return}
        _ = mainAppModel.tellaData?.updateNextcloudReportWithoutFiles(report: currentReport)
    }
    
    func updateReport(reportStatus: ReportStatus? = nil, remoteReportStatus: RemoteReportStatus? = nil , newFileName: String? = nil) {
        
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
    
    override func pauseSubmission() {
        
        updateReport(reportStatus: .submissionPaused)
        
        nextcloudRepository.pauseAllUploads()
        
        deleteChunksFiles()
        
        publishUpdates()
    }
    
    override func deleteReport() {
        let deleteResult = mainAppModel.tellaData?.deleteNextcloudReport(reportId: reportViewModel.id)
        handleDeleteReport(deleteResult: deleteResult ?? false)
    }
    
    func deleteChunksFiles() {
        // Delete the chunks files
        let urlFiles = self.reportViewModel.files.compactMap({$0.url?.directoryURL})
        self.mainAppModel.vaultManager.deleteFiles(files: urlFiles)
        
        // Delete Readme file
        deleteDescriptionFile()
        
    }
    
    func deleteDescriptionFile() {
        guard let descriptionFileUrl = reportViewModel.descriptionFileUrl else { return }
        self.mainAppModel.vaultManager.deleteFiles(files: [descriptionFileUrl])
    }
    
    
}
