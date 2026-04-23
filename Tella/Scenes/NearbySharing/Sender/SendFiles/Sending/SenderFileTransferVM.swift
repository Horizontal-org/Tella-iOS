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
    
    // MARK: - Public Methods
    
    func submitReport() {
        Task { [weak self] in
            guard let self,
                  let repository = self.repository,
                  let session = self.session else { return }
            
            let stagingFolderName = "nearby-sharing-\(session.sessionId)"
            let filesOrdered = self.transferredFiles
            
            await self.prepareFilesForUpload(filesOrdered, stagingFolderName: stagingFolderName)
            
            var shouldStopRemainingUploads = false
            
            for file in filesOrdered {
                if shouldStopRemainingUploads { break }
                
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
                
                if shouldStop {
                    shouldStopRemainingUploads = true
                }
            }
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                if shouldStopRemainingUploads, let session = self.session {
                    self.failRemainingPendingFiles(in: session)
                }
                
                self.checkAllFilesAreReceived()
            }
        }
    }
    
    // MARK: - Overrides
    
    override func stopTask() {
        activeUploadCancellable?.cancel()
        activeUploadCancellable = nil
        repository?.cancelUpload()
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
            
            activeUploadCancellable = repository.uploadFile(
                fileUploadRequest: request,
                fileURL: fileURL
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else {
                    continuation.resume(returning: false)
                    return
                }
                
                let shouldStopRemainingUploads = self.shouldStopRemainingUploads(for: completion)
                
                if shouldStopRemainingUploads {
                    self.repository?.cancelUpload()
                }
                
                self.activeUploadCancellable = nil
                self.finalizeUpload(for: fileID, completion: completion)
                
                continuation.resume(returning: shouldStopRemainingUploads)
            } receiveValue: { [weak self] progress in
                guard let self,
                      let progressFile = self.session?.files[fileID] else { return }
                
                progressFile.bytesReceived += progress
                self.session?.files[fileID] = progressFile
                self.updateProgress(with: progressFile)
            }
        }
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
            // URLSession / transport errors are negative.
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
    
    private func checkAllFilesAreReceived() {
        guard let files = session?.files else { return }
        
        let unfinishedFiles = files.filter {
            $0.value.status == .transferring || $0.value.status == .queue
        }
        
        if unfinishedFiles.isEmpty {
            viewAction = .shouldShowResults
        }
    }
}
