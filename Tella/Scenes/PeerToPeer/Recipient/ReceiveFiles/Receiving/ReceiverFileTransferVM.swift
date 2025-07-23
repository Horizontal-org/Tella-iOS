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
    
    private let peerToPeerServer: PeerToPeerServer?
    private var subscribers = Set<AnyCancellable>()
    
    @Published var progressFile: ProgressFile = ProgressFile()
    @Published var should: Bool = false
    
    // MARK: - Initializer
    
    init?(mainAppModel: MainAppModel) {
        self.peerToPeerServer = mainAppModel.peerToPeerServer
        guard let session = peerToPeerServer?.server.session else { return nil }
        
        super.init(mainAppModel: mainAppModel,
                   title: LocalizablePeerToPeer.receivingAppBar.localized,
                   bottomSheetTitle: LocalizablePeerToPeer.stopReceivingSheetTitle.localized,
                   bottomSheetMessage: LocalizablePeerToPeer.stopReceivingSheetExpl.localized)
        
        transferredFiles = Array(session.files.values)
        initProgress(session: session)
        listenToServer()
    }
    
    // MARK: - Public Methods
    
    func addFiles(parentId: String) {
        let isPreserveMetadataOn = mainAppModel.settings.preserveMetadata
        let finishedFiles = transferredFiles.filter({$0.status == .finished})
        let importedFiles = finishedFiles.compactMap({ImportedFile(urlFile: $0.url,
                                                                   parentId: parentId,
                                                                   shouldPreserveMetadata:isPreserveMetadataOn,
                                                                   deleteOriginal: false,
                                                                   fileSource: .files,
                                                                   fileId: $0.vaultFile.id)})
        addVaultFileWithProgressView(importedFiles: importedFiles)
    }
    
    // MARK: - Private Methods
    
    private func listenToServer() {
        peerToPeerServer?.didSendProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    
                    self.peerToPeerServer?.stopServer()

                    let finishedFiles = transferredFiles.filter({$0.status == .finished})
                    if finishedFiles.isEmpty {
                        viewAction = .shouldShowResults
                    } else {
                        viewAction = .transferIsFinished
                        saveFiles()
                    }
                case .failure:
                    break
                }
            } receiveValue: { [weak self] file in
                self?.updateProgress(with: file)
            }
            .store(in: &subscribers)
    }
    
    private func saveFiles() {
        
        guard let title = progressViewModel?.title else { return }
        
        let result = mainAppModel.vaultFilesManager?.addFolderFile(name: title)
        if case .success(let id) = result  {
            guard let id  else { return  }
            addFiles(parentId: id)
        }
    }
    
    private func addVaultFileWithProgressView(importedFiles: [ImportedFile]) {
        
        self.mainAppModel.vaultFilesManager?.addVaultFile(importedFiles: importedFiles)
            .receive(on: DispatchQueue.main)
            .sink { importVaultFileResult in
                
                switch importVaultFileResult {
                case .fileAdded(let files):
                    let fileIDs = Set(files.map(\.id))
                    
                    self.transferredFiles.forEach { file in
                        if fileIDs.contains(file.vaultFile.id) {
                            file.status = .saved
                        }
                    }
                    
                    self.viewAction = .shouldShowResults
                    
                case .importProgress(let importProgress):
                    self.updateProgress(importProgress:importProgress)
                }
                
            }.store(in: &subscribers)
    }
    
    private func updateProgress(importProgress:ImportProgress) {
        DispatchQueue.main.async {
            self.progressFile.progress = importProgress.progress.value
            self.progressFile.progressFile = importProgress.progressFile.value
            self.progressFile.isFinishing = importProgress.isFinishing.value
        }
    }
    
    // MARK: - Overrides
    
    override func stopTask() {
        peerToPeerServer?.cleanServer()
    }
    
    override func makeTransferredSummary(receivedBytes: Int, totalBytes: Int) -> String {
        let template = transferredFiles.count > 1
        ? LocalizablePeerToPeer.recipientFilesReceived.localized
        : LocalizablePeerToPeer.recipientFileReceived.localized
        
        let receivedFormatted = receivedBytes.getFormattedFileSize().getFileSizeWithoutUnit()
        let totalFormatted = totalBytes.getFormattedFileSize()
        
        return String(format: template, transferredFiles.count, receivedFormatted, totalFormatted)
    }
    
    override func formatPercentage(_ percent: Int) -> String {
        return String(format: LocalizablePeerToPeer.recipientPercentageReceived.localized, percent)
    }
    
}
