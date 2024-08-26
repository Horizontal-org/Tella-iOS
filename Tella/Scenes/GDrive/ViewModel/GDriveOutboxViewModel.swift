//
//  GDriveOutboxViewModel.swift
//  Tella
//
//  Created by gus valbuena on 7/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
import UIKit

class GDriveOutboxViewModel: OutboxMainViewModel<GDriveServer> {
    private let gDriveRepository: GDriveRepositoryProtocol
    private var currentUploadCancellable: AnyCancellable?
    private var uploadQueue: [ReportVaultFile] = []
    var server: GDriveServer?
    
    override var shouldShowCancelUploadConfirmation : Bool {
        return true
    }

    init(mainAppModel: MainAppModel,
         reportsViewModel : ReportsMainViewModel,
         reportId : Int?,
         repository: GDriveRepository) {
        
        self.gDriveRepository = repository
        super.init(mainAppModel: mainAppModel, reportsViewModel: reportsViewModel, reportId: reportId)

        if reportViewModel.status == .submissionScheduled {
            self.submitReport()
        } else {
            self.pauseSubmission()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleAppWillResignActive() {
        if isSubmissionInProgress {
            pauseSubmission()
            updateReportStatus(reportStatus: .submissionPaused)
        }
    }
    
    private func getServer() {
        self.server = mainAppModel.tellaData?.getDriveServers().first
    }
    
    override func initVaultFile(reportId: Int?) {
        getServer()
        
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
                                                   server: server,
                                                   status: report.status,
                                                   apiID: nil,
                                                   folderId: report.folderId)
        }
    }
    
    //submit report
    
    override func submitReport() {
        self.isFileLoading = true
        if isSubmissionInProgress == false {
            self.updateReportStatus(reportStatus: .submissionInProgress)
        }
        gDriveRepository.resumeAllUploads()
        guard let folderId = reportViewModel.folderId else {
            return createDriveFolder()
        }
        
        uploadFiles(to: folderId)
    }
    
    func createDriveFolder() {
        gDriveRepository.createDriveFolder(
            folderName: reportViewModel.title,
            parentId: reportViewModel.server?.rootFolder,
            description: reportViewModel.description
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                self.handleCompletionForCreateFolder(completion)
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
            self.updateReportStatus(reportStatus: .submitted)
            self.showSubmittedReport()
            return
        }
        
        guard let fileUrl = self.mainAppModel.vaultManager.loadVaultFileToURL(file: fileToUpload) else {
            uploadQueue.removeFirst()
            uploadNextFile(folderId: folderId)
            return
        }
        self.isFileLoading = false
        
        let fileUploadDetails = FileUploadDetails(fileURL: fileUrl, 
                                                  fileId: fileToUpload.id ?? "",
                                                  mimeType: fileToUpload.mimeType ?? "",
                                                  folderId: folderId)
        
        currentUploadCancellable = gDriveRepository.uploadFile(fileUploadDetails: fileUploadDetails)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    handleCompletionForUploadFile(completion, folderId: folderId)
                },
                receiveValue: { [weak self] progressInfo in
                    self?.updateProgressInfos(uploadProgressInfo: progressInfo)
                }
            )
    }
    
    private func handleCompletionForUploadFile(_ completion: Subscribers.Completion<APIError>, folderId: String) {
        switch completion {
        case .finished:
            self.uploadQueue.removeFirst()
            self.uploadNextFile(folderId: folderId)
        case .failure( let error):
            switch error {
            default:
                Toast.displayToast(message: error.errorDescription ?? error.localizedDescription)
                updateReportStatus(reportStatus: .submissionError)
            }
        }
    }
    
    private func handleCompletionForCreateFolder(_ completion: Subscribers.Completion<APIError>) {
        switch completion {
        case .finished:
            break
        case .failure( let error):
            switch error {
            default:
                Toast.displayToast(message: error.errorDescription ?? error.localizedDescription)
                updateReportStatus(reportStatus: .submissionError)
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
        
        mainAppModel.tellaData?.updateDriveReportStatus(reportId: id, status: reportStatus)
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
        
        mainAppModel.tellaData?.updateDriveFolderId(reportId: id, folderId: folderId)
    }
    
    override func updateFile(file: ReportVaultFile) {
        guard let reportId = reportViewModel.id else { return }
        
        let reportFiles = reportViewModel.files.map { file in
            return ReportFile(
                id: file.instanceId,
                fileId: file.id,
                status: file.status,
                bytesSent: file.bytesSent,
                createdDate: file.createdDate,
                reportInstanceId: reportViewModel.id
            )
        }
        
        let _ = mainAppModel.tellaData?.updateDriveFiles(reportId: reportId, files: reportFiles)
    }
}
