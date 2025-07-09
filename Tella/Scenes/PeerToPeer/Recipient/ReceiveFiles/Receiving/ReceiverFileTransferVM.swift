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

class ReceiverFileTransferVM: FileTransferVM {
    
    private var server: PeerToPeerServer
    private var subscribers = Set<AnyCancellable>()
    
    init?(mainAppModel: MainAppModel, server: PeerToPeerServer) {
        self.server = server
        
        super.init(mainAppModel: mainAppModel,
                   title: LocalizablePeerToPeer.receivingAppBar.localized,
                   bottomSheetTitle: LocalizablePeerToPeer.stopReceivingSheetTitle.localized,
                   bottomSheetMessage: LocalizablePeerToPeer.stopReceivingSheetExpl.localized)
        
        guard let session = server.server.session else {
            return nil
        }
        
        receivingFiles = Array(session.files.values)
        initProgress(session: session)
        listenToServer()
    }
    
    private func listenToServer() {
        server.didSendProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isLoading = true
                    self?.saveFiles()
                case .failure:
                    break
                }
                debugLog("Completion: \(completion)")
            } receiveValue: { [weak self] file in
                self?.update(file: file)
            }
            .store(in: &subscribers)
    }
    
    private func initProgress(session: P2PSession) {
        let title = session.title ?? ""
        
        // Percent Transferred
        let percentText = String(format: LocalizablePeerToPeer.recipientPercentageReceived.localized, 0)
        
        // Uploaded Files Summary
        let totalSize = receivingFiles.reduce(0) { $0 + ($1.file.size ?? 0) }
        
        let fileTemplate = receivingFiles.count > 1
        ? LocalizablePeerToPeer.recipientFilesReceived.localized
        : LocalizablePeerToPeer.recipientFileReceived.localized
        
        let transferredFilesSummary = String(format: fileTemplate, receivingFiles.count, "0", totalSize.getFormattedFileSize())
        
        // Progress File Items: Transfer Summary
        let progressItems = receivingFiles.map {
            let progression = "0/\(($0.file.size ?? 0).getFormattedFileSize())"
            let fileVM = VaultFileDB(p2pFile: $0.file)
            return ProgressFileItemViewModel(file: fileVM, transferSummary: progression, transferProgress: 0)
        }
        
        self.progressViewModel = ProgressViewModel(title: title,
                                                   percentTransferredText: percentText,
                                                   transferredFilesSummary: transferredFilesSummary,
                                                   percentTransferred: 0,
                                                   progressFileItems: progressItems)
    }
    
    private func update(file: ReceivingFile) {
        let totalBytes = receivingFiles.reduce(0) { $0 + $1.bytesReceived }
        let totalSize = receivingFiles.reduce(0) { $0 + ($1.file.size ?? 0) }
        
        guard totalSize > 0 else { return }
        
        // Percent Transferred
        let progressRatio = Double(totalBytes) / Double(totalSize)
        progressViewModel?.percentTransferred = progressRatio
        
        // Percent Text
        let percent = Int(progressRatio * 100)
        let percentText = String(format: LocalizablePeerToPeer.recipientPercentageReceived.localized, percent)
        progressViewModel?.percentTransferredText = percentText
        
        // Uploaded Files Summary
        let totalUploaded = totalBytes.getFormattedFileSize().getFileSizeWithoutUnit()
        let totalFormattedSize = totalSize.getFormattedFileSize()
        
        let fileTemplate = receivingFiles.count > 1
        ? LocalizablePeerToPeer.recipientFilesReceived.localized
        : LocalizablePeerToPeer.recipientFileReceived.localized
        
        let uploadedFilesSummary = String(format: fileTemplate, receivingFiles.count, totalUploaded, totalFormattedSize)
        
        progressViewModel?.transferredFilesSummary = uploadedFilesSummary
        
        // Progress File Items: Transfer Summary
        if let item = progressViewModel?.progressFileItems.first(where: { $0.file.id == file.file.id }) {
            let uploaded = file.bytesReceived.getFormattedFileSize().getFileSizeWithoutUnit()
            let size = (file.file.size ?? 0).getFormattedFileSize()
            item.transferSummary = "\(uploaded)/\(size)"
        }
    }
    
    override func stopTask() {
        server.stopListening()
    }
    
    private func saveFiles() {
        guard let progressViewModel else { return }
        
        let result = mainAppModel.vaultFilesManager?.addFolderFile(name: progressViewModel.title, parentId: nil)
        
        if case .success = result {
            // Handle success if needed
        }
        
        isLoading = false
    }
}
