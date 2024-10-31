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
    
    init(reportsViewModel: ReportsMainViewModel,
         reportId : Int?,
         repository: NextcloudRepositoryProtocol) {
        
        self.nextcloudRepository = repository
        
        super.init(reportsViewModel: reportsViewModel, reportId: reportId)
        
        self.initSubmission()
    }
    
    override func initVaultFile(reportId: Int?) {
        
        guard
            let reportId,
            let report = self.mainAppModel.tellaData?.getNextcloudReport(id: reportId)
        else {
            return
        }
        currentReport = report
        let files = processVaultFiles(reportFiles: report.reportFiles)
        self.reportViewModel = ReportViewModel(report: report, files: files)
    }
    
    override func submitReport() {
        
        Task {
            do {
                
                let server = try NextcloudServerModel(server: currentReport?.server)
                
                self.updateReport(reportStatus: .submissionInProgress)
                
                let reportToSend = try await prepareReportToSend(server: server)
                
                nextcloudRepository.uploadReport(report: reportToSend)
                    .sink { completion in
                        
                        self.handleSubmitReportCompletion(completion: completion)
                        
                    } receiveValue: { response in
                        self.processUploadReportResponse(response:response)
                    }.store(in: &subscribers)
                
            } catch let error {
                if let error = error as? RuntimeError {
                    self.toastMessage = error.message
                    self.shouldShowToast = true
                }
            }
        }
    }
    
    private func prepareReportToSend(server:NextcloudServerModel) async throws -> NextcloudReportToSend {
        
        let files = reportViewModel.files.filter({ $0.status != .submitted})
        
        for file in files {
            file.url =  await self.mainAppModel.vaultManager.loadVaultFileToURLAsync(file: file, withSubFolder: true)
        }
        
        let remoteFolderName = self.reportViewModel.title.removeForbiddenCharacters()
        
        if reportViewModel.remoteReportStatus != .descriptionSent {
            guard let descriptionFileUrl = self.mainAppModel.vaultManager.getDescriptionFileUrl(content: self.reportViewModel.description,
                                                                                                fileName: NextcloudConstants.descriptionFolderName)
            else { throw RuntimeError(LocalizableCommon.commonError.localized) }
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
                                      fileSize: file.size,
                                      remoteFolderName: remoteFolderName,
                                      serverURL: server.url,
                                      chunkFolder: chunkFolder,
                                      chunkFiles: chunkFiles)
        }
        
        return NextcloudReportToSend(folderName: remoteFolderName,
                                     descriptionFileUrl: reportViewModel.descriptionFileUrl,
                                     remoteReportStatus: currentReport?.remoteReportStatus ?? .initial,
                                     files: filesToSend,
                                     server: server)
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
        case .folderRecreated:
            Toast.displayToast(message: LocalizableNextcloud.recreateFolderMsg.localized)
        case .initial:
            break
        }
    }
    
    override func deleteFilesAfterSubmission() {
        deleteChunksFiles()
    }
    
    private func addChunks(uploadProgressInfo : NextcloudUploadProgressInfo) {
        
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
    
    private func removeChunks(uploadProgressInfo : NextcloudUploadProgressInfo) {
        
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
        if let fileURL = currentFile.url?.createURL(name: chunkSent.fileName) {
            self.mainAppModel.vaultManager.deleteFiles(files: [fileURL])
        }
        
        // Update the file
        self.updateFile(file: currentFile)
        
    }
    
    override func updateFile(file:ReportVaultFile) {
        guard let file = NextcloudReportFile(reportFile: file) else {return}
        let _ = mainAppModel.tellaData?.updateNextcloudReportFile(reportFile: file)
    }
    
    override func updateReport() {
        guard let currentReport else {return}
        _ = mainAppModel.tellaData?.updateNextcloudReportWithoutFiles(report: currentReport)
    }
    
    override func updateReport(reportStatus: ReportStatus? = nil,
                               remoteReportStatus: RemoteReportStatus? = nil ,
                               newFileName: String? = nil) {
        
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
        guard
            let deleteResult = mainAppModel.tellaData?.deleteNextcloudReport(reportId: reportViewModel.id)
        else {
            return
        }
        handleDeleteReport(deleteResult: deleteResult)
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
