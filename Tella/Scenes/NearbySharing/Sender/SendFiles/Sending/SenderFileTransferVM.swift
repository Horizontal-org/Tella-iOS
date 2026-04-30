//
//  SenderFileTransferVM.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 15/5/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Combine

class SenderFileTransferVM: FileTransferVM {
    
    var repository: NearbySharingRepository?
    var session: NearbySharingSession?
    
    private var activeUploadCancellable: AnyCancellable?
    private var closeConnectionCancellable: AnyCancellable?
    private var submitReportTask: Task<Void, Never>?
    private var didCancelTransfer = false
    private var didShowResults = false
    private var uploadContinuation: CheckedContinuation<Bool, Never>?
    
    init(mainAppModel: MainAppModel,
         repository: NearbySharingRepository,
         session: NearbySharingSession) {
        
        self.repository = repository
        self.session = session
        
        super.init(mainAppModel: mainAppModel,
                   title: LocalizableNearbySharing.senderSendingAppBar.localized,
                   bottomSheetTitle: LocalizableNearbySharing.stopSharingTitle.localized,
                   bottomSheetMessage: LocalizableNearbySharing.stopSharingSheetExpl.localized)
        
        transferredFiles = Array(session.files.values)
        initProgress(session: session)
        submitReport()
    }
    
    deinit {
        submitReportTask?.cancel()
        activeUploadCancellable?.cancel()
        closeConnectionCancellable?.cancel()
        resumeUploadContinuation(false)
    }
    
    // MARK: - Public Methods
    
    func submitReport() {
        submitReportTask?.cancel()
        activeUploadCancellable?.cancel()
        resumeUploadContinuation(false)
        
        didCancelTransfer = false
        didShowResults = false
        
        submitReportTask = Task { [weak self] in
            guard let self,
                  let repository = self.repository,
                  let session = self.session else { return }
            
            let stagingFolderName = "nearby-sharing-\(session.sessionId)"
            let filesOrdered = self.transferredFiles
            
            await self.prepareFilesForUpload(filesOrdered, stagingFolderName: stagingFolderName)
            
            guard !Task.isCancelled else { return }
            
            var shouldStopRemainingUploads = false
            
            for file in filesOrdered {
                if Task.isCancelled || shouldStopRemainingUploads {
                    break
                }
                
                guard let fileURL = file.url,
                      let fileID = file.file.id else {
                    continue
                }
                
                let request = FileUploadRequest(
                    sessionID: session.sessionId,
                    transmissionID: file.transmissionId,
                    fileID: fileID,
                    nonce: NearbySharingTransferNonce.make()
                )
                
                let shouldStop = await self.uploadSingleFile(
                    repository: repository,
                    request: request,
                    fileURL: fileURL,
                    fileID: fileID
                )
                
                if Task.isCancelled {
                    break
                }
                
                if shouldStop {
                    shouldStopRemainingUploads = true
                }
            }
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                if self.didCancelTransfer || shouldStopRemainingUploads {
                    self.failTransferAndShowResults()
                } else {
                    self.showResultsIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Overrides
    
    override func stopTask() {
        didCancelTransfer = true
        failTransferAndShowResults(forceShowResults: true)
        closeConnection()
    }
    
    override func makeTransferredSummary(receivedBytes: Int, totalBytes: Int) -> String {
        let template = transferredFiles.count > 1
        ? LocalizableNearbySharing.recipientFilesReceived.localized
        : LocalizableNearbySharing.recipientFileReceived.localized
        
        let receivedFormatted = receivedBytes.getFormattedFileSize().getFileSizeWithoutUnit()
        let totalFormatted = totalBytes.getFormattedFileSize()
        
        return String(format: template, transferredFiles.count, receivedFormatted, totalFormatted)
    }
    
    override func formatPercentage(_ percent: Int) -> String {
        String(format: LocalizableNearbySharing.recipientPercentageReceived.localized, percent)
    }
    
    // MARK: - Helpers
    
    private func prepareFilesForUpload(_ files: [NearbySharingTransferredFile], stagingFolderName: String) async {
        for file in files {
            if Task.isCancelled { return }
            
            file.url = await mainAppModel.vaultManager.loadVaultFileToURLAsync(
                file: file.vaultFile,
                withSubFolder: true,
                subFolderName: stagingFolderName
            )
        }
    }
    
    private func uploadSingleFile(
        repository: NearbySharingRepository,
        request: FileUploadRequest,
        fileURL: URL,
        fileID: String
    ) async -> Bool {
        await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            activeUploadCancellable?.cancel()
            activeUploadCancellable = nil
            resumeUploadContinuation(false)
            
            uploadContinuation = continuation
            
            activeUploadCancellable = repository.uploadFile(
                fileUploadRequest: request,
                fileURL: fileURL
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                
                self.activeUploadCancellable = nil
                
                if self.submitReportTask?.isCancelled == true || self.didCancelTransfer {
                    self.resumeUploadContinuation(false)
                    return
                }
                
                let shouldStopRemainingUploads = self.shouldStopRemainingUploads(for: completion)
                
                self.finalizeUpload(for: fileID, completion: completion)
                
                if shouldStopRemainingUploads {
                    self.failTransferAndShowResults()
                } else {
                    self.resumeUploadContinuation(false)
                }
                
            } receiveValue: { [weak self] progress in
                guard let self,
                      self.submitReportTask?.isCancelled != true,
                      !self.didCancelTransfer,
                      let progressFile = self.session?.files[fileID] else { return }
                
                progressFile.bytesReceived += progress
                self.session?.files[fileID] = progressFile
                self.updateProgress(with: progressFile)
            }
        }
    }
    
    private func resumeUploadContinuation(_ value: Bool) {
        uploadContinuation?.resume(returning: value)
        uploadContinuation = nil
    }
    
    private func shouldStopRemainingUploads(
        for completion: Subscribers.Completion<APIError>
    ) -> Bool {
        guard case .failure(let apiError) = completion else {
            return false
        }
        
        switch apiError {
        case .httpCode(let code):
            if code == HTTPStatusCode.insufficientStorage.rawValue {
                return true
            }
            return code < 0
            
        case .unexpectedResponse, .badServer, .noInternetConnection:
            return true
            
        default:
            return false
        }
    }
    
    private func finalizeUpload(
        for fileID: String,
        completion: Subscribers.Completion<APIError>
    ) {
        guard let progressFile = session?.files[fileID] else { return }
        
        cleanupTemporaryFile(for: progressFile)
        
        switch completion {
        case .finished:
            progressFile.status = .finished
        case .failure:
            progressFile.status = .failed
        }
        
        session?.files[fileID] = progressFile
        updateStatus(with: progressFile)
        updateProgress(with: progressFile)
    }
    
    private func cleanupTemporaryFile(for file: NearbySharingTransferredFile) {
        guard let tempURL = file.url else { return }
        
        mainAppModel.vaultManager.deleteTmpFilesWithParents(files: [tempURL])
        file.url = nil
    }
    
    private func failRemainingPendingFiles(in session: NearbySharingSession) {
        for key in session.files.keys {
            guard let fileEntry = session.files[key],
                  fileEntry.status != .finished else {
                continue
            }
            
            fileEntry.status = .failed
            session.files[key] = fileEntry
            updateStatus(with: fileEntry)
            updateProgress(with: fileEntry)
        }
    }
    
    private func showResultsIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  !self.didShowResults,
                  let files = self.session?.files else { return }
            
            let unfinishedFiles = files.filter {
                $0.value.status == .transferring || $0.value.status == .queue
            }
            
            guard unfinishedFiles.isEmpty else { return }
            
            self.showResultsView()
        }
    }
    
    private func showResultsView(force: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            guard force || !self.didShowResults else { return }
            
            self.didShowResults = true
            self.viewAction = .shouldShowResults
        }
    }
    
    private func closeConnection() {
        guard let repository = repository,
              let sessionID = session?.sessionId else {
            return
        }
        
        let request = CloseConnectionRequest(sessionID: sessionID)
        
        closeConnectionCancellable?.cancel()
        closeConnectionCancellable = repository.closeConnection(closeConnectionRequest: request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.closeConnectionCancellable = nil
                },
                receiveValue: { _ in }
            )
    }
    
    private func failTransferAndShowResults(forceShowResults: Bool = false) {
        submitReportTask?.cancel()
        submitReportTask = nil
        
        activeUploadCancellable?.cancel()
        activeUploadCancellable = nil
        
        repository?.cancelUpload()
        resumeUploadContinuation(true)
        
        if let session = session {
            failRemainingPendingFiles(in: session)
        }
        
        showResultsView(force: forceShowResults)
    }
}
