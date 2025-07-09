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
    
    private let server: PeerToPeerServer
    private var subscribers = Set<AnyCancellable>()
    private var receivingFiles: [ReceivingFile] = []
    
    @Published var progressFile: ProgressFile = ProgressFile()
    @Published var should: Bool = false
    
    // MARK: - Initializer
    
    init?(mainAppModel: MainAppModel, server: PeerToPeerServer) {
        self.server = server
        
        guard let session = server.server.session else { return nil }
        
        receivingFiles = Array(session.files.values)
        
        super.init(mainAppModel: mainAppModel,
                   title: LocalizablePeerToPeer.receivingAppBar.localized,
                   bottomSheetTitle: LocalizablePeerToPeer.stopReceivingSheetTitle.localized,
                   bottomSheetMessage: LocalizablePeerToPeer.stopReceivingSheetExpl.localized)
        
        initProgress(session: session)
        listenToServer()
    }
    
    // MARK: - Private Methods
    
    private func listenToServer() {
        server.didSendProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    isLoading = true
                    viewAction = .transferIsFinished
                    saveFiles()
                case .failure:
                    break
                }
            } receiveValue: { [weak self] file in
                self?.updateProgress(with: file)
            }
            .store(in: &subscribers)
    }
    
    private func initProgress(session: P2PSession) {
        let title = session.title ?? ""
        let totalSize = receivingFiles.reduce(0) { $0 + ($1.file.size ?? 0) }
        
        let progressItems = receivingFiles.map(makeProgressItem)
        
        progressViewModel = ProgressViewModel(
            title: title,
            percentTransferredText: formatPercentage(0),
            transferredFilesSummary: makeTransferredSummary(receivedBytes: 0, totalBytes: totalSize),
            percentTransferred: 0,
            progressFileItems: progressItems
        )
    }
    
    private func updateProgress(with file: ReceivingFile) {
        let totalBytesReceived = receivingFiles.reduce(0) { $0 + $1.bytesReceived }
        let totalBytes = receivingFiles.reduce(0) { $0 + ($1.file.size ?? 0) }
        
        guard totalBytes > 0 else { return }
        
        let ratio = Double(totalBytesReceived) / Double(totalBytes)
        progressViewModel?.percentTransferred = ratio
        progressViewModel?.percentTransferredText = formatPercentage(Int(ratio * 100))
        progressViewModel?.transferredFilesSummary = makeTransferredSummary(receivedBytes: totalBytesReceived, totalBytes: totalBytes)
        
        // Update individual file progress
        if let item = progressViewModel?.progressFileItems.first(where: { $0.file.id == file.file.id }) {
            let received = file.bytesReceived.getFormattedFileSize().getFileSizeWithoutUnit()
            let total = (file.file.size ?? 0).getFormattedFileSize()
            item.transferSummary = "\(received)/\(total)"
        }
    }
    
    override func stopTask() {
        server.cleanServer()
    }
    
    // MARK: - Helpers
    
    private func makeTransferredSummary(receivedBytes: Int, totalBytes: Int) -> String {
        let template = receivingFiles.count > 1
        ? LocalizablePeerToPeer.recipientFilesReceived.localized
        : LocalizablePeerToPeer.recipientFileReceived.localized
        
        let receivedFormatted = receivedBytes.getFormattedFileSize().getFileSizeWithoutUnit()
        let totalFormatted = totalBytes.getFormattedFileSize()
        
        return String(format: template, receivingFiles.count, receivedFormatted, totalFormatted)
    }
    
    private func makeProgressItem(from file: ReceivingFile) -> ProgressFileItemViewModel {
        let size = (file.file.size ?? 0).getFormattedFileSize()
        let summary = "0/\(size)"
        return ProgressFileItemViewModel(
            file: VaultFileDB(p2pFile: file.file),
            transferSummary: summary,
            transferProgress: 0
        )
    }
    
    private func formatPercentage(_ percent: Int) -> String {
        return String(format: LocalizablePeerToPeer.recipientPercentageReceived.localized, percent)
    }
    
    private func saveFiles() {
        
        
        guard let title = progressViewModel?.title else { return }
        
        let result = mainAppModel.vaultFilesManager?.addFolderFile(name: title)
        if case .success(let id) = result  {
            guard let id  else { return  }
            let urls: [URL] = receivingFiles.compactMap({$0.path})
            addFiles(urls: urls, parentId: id)
        }
        
        isLoading = false
    }
    
    func addFiles(urls:[URL], parentId: String) {
        let isPreserveMetadataOn = mainAppModel.settings.preserveMetadata
        
        let importedFiles = urls.compactMap({ImportedFile(urlFile: $0,
                                                          parentId: parentId,
                                                          shouldPreserveMetadata:isPreserveMetadataOn,
                                                          deleteOriginal: false,
                                                          fileSource: .files)})
        addVaultFileWithProgressView(importedFiles: importedFiles)
    }

    private func addVaultFileWithProgressView(importedFiles: [ImportedFile]) {
        
        self.mainAppModel.vaultFilesManager?.addVaultFile(importedFiles: importedFiles)
            .sink { importVaultFileResult in
                
                switch importVaultFileResult {
                case .fileAdded:
                    self.server.stopServer()
                    self.viewAction = .filesAreSaved
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
}
