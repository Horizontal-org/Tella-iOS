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
    private var rootFolderTask: Task<VaultFileDB?, Never>?

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
            .compactMap { event -> NearbySharingTransferredFile? in
                if case let .fileTransferProgress(file) = event { return file }
                return nil
            }
            .sink { [weak self] file in
                guard let self else { return }
                Task { await self.handle(file: file) }
            }
            .store(in: &subscribers)
    }

    private func ensureRootFolder() async -> VaultFileDB? {
        if let task = rootFolderTask { return await task.value }
        
        let task = Task<VaultFileDB?, Never> { [weak self] in
            guard let self else { return nil }
            return await self.saveFolder()
        }
        rootFolderTask = task
        
        let value = await task.value
        if value == nil { rootFolderTask = nil } // retry on next call if creation failed
        self.rootFile = value
        return value
    }
    
    // MARK: - Event handling
    
    private func handle(file: NearbySharingTransferredFile) async {
        guard let fileID = file.vaultFile.id else { return }
        
        switch file.status {
        case .finished:
            if let transferred = transferredFiles.first(where: { $0.vaultFile.id == fileID }) {
                transferred.status = .saving
                self.updateStatus(with: transferred)
            }
            
            guard
                let parent = await ensureRootFolder(),
                let manager = self.mainAppModel.vaultFilesManager
            else {
                markFailed(id: fileID)
                return
            }
            
            let imported = ImportedFile(
                urlFile: file.url,
                parentId: parent.id,
                shouldPreserveMetadata: true,
                deleteOriginal: true,
                fileSource: .files,
                fileId: fileID,
                fileName: file.vaultFile.name
            )
            
            if await manager.addVaultFile(importedFile: imported) != nil {
                markSaved(id: fileID)
            } else {
                markFailed(id: fileID)
            }
            
            checkAllFilesAreReceived()
            
        case .failed:
            markFailed(id: fileID)
            checkAllFilesAreReceived()
            
        default:
            self.updateProgress(with: file)
        }
    }
    
    // MARK: - UI helpers
    
    private func markSaved(id: String) {
        guard let transferred = transferredFiles.first(where: { $0.vaultFile.id == id }) else { return }
        transferred.status = .saved
        updateStatus(with: transferred)
    }
    
    private func markFailed(id: String) {
        guard let transferred = transferredFiles.first(where: { $0.vaultFile.id == id }) else { return }
        transferred.status = .failed
        updateStatus(with: transferred)
    }
    
    // MARK: - Folder creation
    
    private func saveFolder() async -> VaultFileDB? {
        
        guard let title = progressViewModel?.title, !title.isEmpty else { return nil }
        guard let manager = mainAppModel.vaultFilesManager else { return nil }
        
        let result = manager.addFolderFile(name: title)
        if case .success(let id) = result {
            guard let id  else { return nil }
            return mainAppModel.vaultFilesManager?.getVaultFile(id: id)
        }
        return nil
    }
    
    // MARK: - Completion check
    
    private func checkAllFilesAreReceived()  {
        Task {
            // Read & act on UI state on the main actor
            let allDone = self.transferredFiles.allSatisfy { $0.status == .saved || $0.status == .failed }
            
            if allDone {
                await MainActor.run {
                    self.viewAction = .shouldShowResults
                }
                nearbySharingServer?.resetFullServerState()
            }
        }
    }
    
    // MARK: - Overrides
    
    override func stopTask() {
        // Reset server state
        nearbySharingServer?.resetFullServerState()
        
        // Mark any in-progress files as failed
        for file in transferredFiles where file.status != .saved && file.status != .failed {
            file.status = .failed
        }
        
        // Trigger UI update
        viewAction = .shouldShowResults
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
