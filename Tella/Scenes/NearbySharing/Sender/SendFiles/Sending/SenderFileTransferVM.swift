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
    private var subscribers = Set<AnyCancellable>()
    
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
        
        Task {
            
            guard let vaultfiles = session?.files.values else { return }
            
            for file in vaultfiles {
                file.url =  await self.mainAppModel.vaultManager.loadVaultFileToURLAsync(file: file.vaultFile, withSubFolder: true)
            }
            
            vaultfiles.forEach({ file in
                guard let url = file.url else { return }
                let fileID = file.file.id
                repository?.uploadFile(fileUploadRequest: FileUploadRequest(sessionID: session?.sessionId,
                                                                            transmissionID: file.transmissionId,
                                                                            fileID: fileID),
                                       fileURL: url)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    
                    guard let fileID,  let progressFile = self.session?.files[fileID] else {return}

                    switch completion {
                    case .finished:
                         progressFile.status = .finished
                    case .failure:
                        progressFile.status = .failed
                    }

                    self.session?.files[fileID] = progressFile

                    self.checkAllFilesAreReceived()

                } receiveValue: { progress in
                    guard let fileID,  let progressFile = self.session?.files[fileID] else {return}
                    progressFile.bytesReceived += progress
                    self.session?.files[fileID] = progressFile
                    self.updateProgress(with: progressFile)
                }.store(in: &subscribers)
            })
        }
    }
    
    private func checkAllFilesAreReceived()  {
        guard let files = session?.files else { return  }
        let filesAreNotfinishReceiving = files.filter({$0.value.status == .transferring || $0.value.status == .queue})
        if (filesAreNotfinishReceiving.isEmpty) {
            self.viewAction = .transferIsFinished
        }
    }
    
    // MARK: - Overrides
    
    override func stopTask() {
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
