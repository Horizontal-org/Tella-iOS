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
            guard let self else { return }
            guard let repository = self.repository, let session = self.session else { return }
            
            let stagingFolderName = "nearby-sharing-\(session.sessionId)"
            let filesOrdered = self.transferredFiles
            var stopRemainingUploads = false
            
            for file in filesOrdered {
                file.url = await self.mainAppModel.vaultManager.loadVaultFileToURLAsync(
                    file: file.vaultFile,
                    withSubFolder: true,
                    subFolderName: stagingFolderName
                )
            }
            
            for file in filesOrdered {
                if stopRemainingUploads {
                    break
                }
                guard let url = file.url, let fileID = file.file.id else { continue }
                
                let request = FileUploadRequest(
                    sessionID: session.sessionId,
                    transmissionID: file.transmissionId,
                    fileID: fileID,
                    nonce: NearbySharingTransferNonce.make()
                )
                
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    self.activeUploadCancellable?.cancel()
                    self.activeUploadCancellable = repository.uploadFile(fileUploadRequest: request, fileURL: url)
                        .receive(on: DispatchQueue.main)
                        .sink { [weak self] completion in
                            guard let self else {
                                continuation.resume()
                                return
                            }

                            var isInsufficientStorage = false
                            if case .failure(let apiError) = completion,
                               case .httpCode(let code) = apiError,
                               code == HTTPStatusCode.insufficientStorage.rawValue {
                                isInsufficientStorage = true
                            }

                            if isInsufficientStorage {
                                stopRemainingUploads = true
                                self.repository?.cancelUpload()
                            }

                            self.activeUploadCancellable = nil

                            guard let progressFile = self.session?.files[fileID] else {
                                continuation.resume()
                                return
                            }

                            if let tempURL = progressFile.url {
                                self.mainAppModel.vaultManager.deleteTmpFilesWithParents(files: [tempURL])
                                progressFile.url = nil
                            }

                            switch completion {
                            case .finished:
                                progressFile.status = .finished
                            case .failure:
                                progressFile.status = .failed
                            }
                            self.session?.files[fileID] = progressFile

                            continuation.resume()
                        } receiveValue: { [weak self] progress in
                            guard let self,
                                  let progressFile = self.session?.files[fileID] else { return }
                            progressFile.bytesReceived += progress
                            self.session?.files[fileID] = progressFile
                            self.updateProgress(with: progressFile)
                        }
                }
            }
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                if stopRemainingUploads, let session = self.session {
                    for key in session.files.keys {
                        guard var fileEntry = session.files[key], fileEntry.status != .finished else { continue }
                        fileEntry.status = .failed
                        session.files[key] = fileEntry
                    }
                }
                self.checkAllFilesAreReceived()
            }
        }
    }
    
    private func checkAllFilesAreReceived()  {
        guard let files = session?.files else { return  }
        let filesAreNotfinishReceiving = files.filter({$0.value.status == .transferring || $0.value.status == .queue})
        if (filesAreNotfinishReceiving.isEmpty) {
            self.viewAction = .shouldShowResults
        }
    }
    
    // MARK: - Overrides
    
    override func stopTask() {
        activeUploadCancellable?.cancel()
        activeUploadCancellable = nil
        repository?.cancelUpload()
    }
    
    // MARK: - Helpers
    
    override func makeTransferredSummary(receivedBytes: Int, totalBytes: Int) -> String {
        let template = transferredFiles.count > 1
        ? LocalizableNearbySharing.recipientFilesReceived.localized
        : LocalizableNearbySharing.recipientFileReceived.localized
        
        let receivedFormatted = receivedBytes.getFormattedFileSize().getFileSizeWithoutUnit()
        let totalFormatted = totalBytes.getFormattedFileSize()
        
        return String(format: template, transferredFiles.count, receivedFormatted, totalFormatted)
    }
    
    override func formatPercentage(_ percent: Int) -> String {
        return String(format: LocalizableNearbySharing.recipientPercentageReceived.localized, percent)
    }
}
