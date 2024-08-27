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
    
    override func initVaultFile(reportId: Int?) {
        if let reportId, let report = self.mainAppModel.tellaData?.getDriveReport(id: reportId) {
            let files = processVaultFiles(reportFiles: report.reportFiles)
            
            self.reportViewModel = ReportViewModel(report: report, files: files)
        }
    }
    
    //submit report
    
    override func submitReport() {
        if isSubmissionInProgress { return }
        
        self.updateReportStatus(reportStatus: .submissionInProgress)
        
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
        
        Task {
            guard let fileUrl = await self.loadVaultFileToURLAsync(file: fileToUpload) else {
                await MainActor.run {
                    uploadQueue.removeFirst()
                    uploadNextFile(folderId: folderId)
                }
                return
            }
            
            let fileUploadDetails = FileUploadDetails(fileURL: fileUrl,
                                                      fileId: fileToUpload.id ?? "",
                                                      mimeType: fileToUpload.mimeType ?? "",
                                                      folderId: folderId)
            
            await MainActor.run {
                currentUploadCancellable = gDriveRepository.uploadFile(fileUploadDetails: fileUploadDetails)
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { [weak self] completion in
                            guard let self = self else { return }
                            self.handleCompletionForUploadFile(completion, folderId: folderId)
                        },
                        receiveValue: { [weak self] progressInfo in
                            self?.updateProgressInfos(uploadProgressInfo: progressInfo)
                        }
                    )
            }
        }
    }
    
    private func handleCompletionForUploadFile(_ completion: Subscribers.Completion<APIError>, folderId: String) {
        switch completion {
        case .finished:
            if !self.uploadQueue.isEmpty {
                self.uploadQueue.removeFirst()
            }
            self.uploadNextFile(folderId: folderId)
        case .failure( let error):
            switch error {
            default:
                Toast.displayToast(message: error.errorMessage)
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
                Toast.displayToast(message: error.errorMessage)
                updateReportStatus(reportStatus: .submissionError)
            }
        }
    }
    
    override func pauseSubmission() {
        if isSubmissionInProgress {
            updateReportStatus(reportStatus: .submissionPaused)
            gDriveRepository.pauseAllUploads()
            currentUploadCancellable = nil
        }
    }
    
    override func updateReportStatus(reportStatus: ReportStatus) {
        self.reportViewModel.status = reportStatus
        
        guard let id = reportViewModel.id else { return }
        
        mainAppModel.tellaData?.updateDriveReportStatus(reportId: id, status: reportStatus)
    }
    
    private func updateReportFolderId(folderId: String) {
        guard let id = reportViewModel.id else { return }
        
        mainAppModel.tellaData?.updateDriveFolderId(reportId: id, folderId: folderId)
    }
    
    override func updateFileProgress(progressInfo:UploadProgressInfo) {
        guard let reportId = reportViewModel.id else { return }
        
        let reportFiles = reportViewModel.files.map { file in
            return ReportFile(
                file: file,
                reportInstanceId: reportViewModel.id
            )
        }
        
        let _ = mainAppModel.tellaData?.updateDriveFiles(reportId: reportId, files: reportFiles)
    }
    
    func loadVaultFileToURLAsync(file: ReportVaultFile) async -> URL? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = self.mainAppModel.vaultManager.loadVaultFileToURL(file: file)
                continuation.resume(returning: result)
            }
        }
    }
}
