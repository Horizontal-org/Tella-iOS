//
//  ReceiverFileTransferVM.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 7/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Combine
import Foundation

final class ReceiverFileTransferVM: FileTransferVM {
    
    // MARK: - Properties
    
    private let nearbySharingServer: NearbySharingServer?
    private var subscribers = Set<AnyCancellable>()
    
    @Published var should: Bool = false
    
    var rootFile: VaultFileDB? = nil
    
    // MARK: - Initializer
    
    init?(mainAppModel: MainAppModel) {
        self.nearbySharingServer = mainAppModel.nearbySharingServer
        guard nearbySharingServer != nil else { return nil }
        
        super.init(
            mainAppModel: mainAppModel,
            title: LocalizableNearbySharing.receivingAppBar.localized,
            bottomSheetTitle: LocalizableNearbySharing.stopReceivingSheetTitle.localized,
            bottomSheetMessage: LocalizableNearbySharing.stopReceivingSheetExpl.localized
        )
        Task { [weak self] in
            guard let self, let server = self.nearbySharingServer else { return }
            if let session = await server.state.currentSession() {
                self.transferredFiles = Array(session.files.values)
                self.initProgress(session: session)
                self.listenToServer()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func listenToServer() {
        nearbySharingServer?.eventPublisher
            .sink { [weak self] event in
                guard let self else { return }
                
                switch event {
                case .fileTransferProgress(let file):
                    handle(file: file)
                default:
                    break
                }
            }
            .store(in: &subscribers)
    }
    
    private func handle(file: NearbySharingTransferredFile) {
        Task {
            
            if file.status == .finished {
                
                guard let transferredFile = self.transferredFiles.first(where: {$0.vaultFile.id == file.vaultFile.id}) else {return}
                
                transferredFile.status = .saving
                self.updateStatus(with: transferredFile)
                
                if self.rootFile == nil {
                    self.rootFile = await self.saveFolder()
                }
                guard let parentId = self.rootFile?.id  else { return }
                
                let importedFile = ImportedFile(urlFile: file.url,
                                                parentId: parentId,
                                                shouldPreserveMetadata:true,
                                                deleteOriginal: true,
                                                fileSource: .files,
                                                fileId: file.vaultFile.id,
                                                fileName:file.vaultFile.name)
                
                guard let _ = await self.mainAppModel.vaultFilesManager?.addVaultFile(importedFile: importedFile) else {
                    transferredFile.status = .failed
                    self.updateStatus(with: transferredFile)
                    return
                }
                
                transferredFile.status = .saved
                self.updateStatus(with: transferredFile)
                
                checkAllFilesAreReceived()
                
            } else if file.status == .failed {
                guard let transferredFile = self.transferredFiles.first(where: {$0.vaultFile.id == file.vaultFile.id}) else {return}
                
                transferredFile.status = .failed
                self.updateStatus(with: transferredFile)
                
                checkAllFilesAreReceived()
                
            } else {
                await MainActor.run {
                    self.updateProgress(with: file)
                }
            }
        }
    }
    
    private func saveFolder() async -> VaultFileDB? {
        
        guard let title = progressViewModel?.title else { return nil }
        
        let result = mainAppModel.vaultFilesManager?.addFolderFile(name: title)
        if case .success(let id) = result {
            guard let id  else { return nil }
            return mainAppModel.vaultFilesManager?.getVaultFile(id: id)
        } else {
            return nil
        }
    }
    
    private func checkAllFilesAreReceived() {
        Task {
            let filesAreNotfinishing = transferredFiles.first { $0.status != .saved && $0.status != .failed } == nil
            
            if (filesAreNotfinishing) {
                await MainActor.run {
                    self.viewAction = .shouldShowResults
                }
                self.nearbySharingServer?.cleanServer()
            }
        }
    }
    
    // MARK: - Overrides
    
    override func stopTask() {
        nearbySharingServer?.resetFullServerState()
        _ = transferredFiles.compactMap({$0.status = .failed})
        self.viewAction = .shouldShowResults
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
        return String(format: LocalizableNearbySharing.recipientPercentageReceived.localized, percent)
    }
    
}
