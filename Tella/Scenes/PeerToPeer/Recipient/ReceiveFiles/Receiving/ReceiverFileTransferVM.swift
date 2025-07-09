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
    
    var server: PeerToPeerServer
    private var subscribers = Set<AnyCancellable>()
    
    init?(mainAppModel: MainAppModel,
          server: PeerToPeerServer) {
        
        self.server = server
        
        super.init(mainAppModel: mainAppModel,
                   title: LocalizablePeerToPeer.receivingAppBar.localized,
                   bottomSheetTitle: LocalizablePeerToPeer.stopReceivingSheetTitle.localized,
                   bottomSheetMessage: LocalizablePeerToPeer.stopReceivingSheetExpl.localized)
        
        
        listenToServer()
        
        self.initProgress()
    }
    
    func listenToServer() {
        
        server.didSendProgress
            .receive(on: DispatchQueue.main)
        
            .sink { completion in
                
                switch completion {
                case .finished:
                    self.isLoading = true
                    self.saveFiles()
                case .failure:
                    break
                }
                debugLog("Completion: \(completion)")
            } receiveValue: { file in
                self.update(file: file)
            }.store(in: &subscribers)
    }
    
    func initProgress() {
        
        // Title
        let title = self.server.server.session?.title ?? ""
        guard let session = server.server.session else {
            return
        }
        
        receivingFiles = Array(session.files.values)
        
        // PercentUploadedInfo
        let percentTransferredText = String.init(format: LocalizablePeerToPeer.recipientPercentageReceived.localized,0)
        
        // UploadedFiles
        let totalSize = receivingFiles.reduce(into: 0) { $0 += $1.file.size ?? 0 }
        let fileString = receivingFiles.count > 1 ? LocalizablePeerToPeer.recipientFilesReceived.localized : LocalizablePeerToPeer.recipientFileReceived.localized
        let transferredFilesSummary = String(format: fileString,  receivingFiles.count, "0", totalSize.getFormattedFileSize() )
        
        // ProgressFileItems
        
        let progressFileItems = receivingFiles.compactMap { receivingFile in
            let progression = "0/\((receivingFile.file.size ?? 0).getFormattedFileSize())"
            let vaultFileDB = VaultFileDB.init(p2pFile: receivingFile.file)
            return ProgressFileItemViewModel(file: vaultFileDB, transferSummary: progression, transferProgress: 0)
        }
        
        self.progressViewModel = ProgressViewModel(title: title,
                                                   percentTransferredText: percentTransferredText,
                                                   transferredFilesSummary: transferredFilesSummary,
                                                   percentTransferred: 0,
                                                   progressFileItems: progressFileItems)
    }
    
    func update(file : ReceivingFile) {
        
        let totalBytesSent = receivingFiles.reduce(into: 0) { $0 += $1.bytesReceived }
        let totalSize = receivingFiles.reduce(into: 0) { $0 += $1.file.size ?? 0 }
        let recipientPercentage = Float(totalBytesSent) / Float(totalSize)
        let formattedRecipientPercentage = Int(recipientPercentage * 100)
        
        
        let percentUploadedInfo = String.init(format: LocalizablePeerToPeer.recipientPercentageReceived.localized,formattedRecipientPercentage )
        
        let formattedTotalUploaded = totalBytesSent.getFormattedFileSize().getFileSizeWithoutUnit()
        let formattedTotalSize = totalSize.getFormattedFileSize()
        
        // UploadedFiles
        let fileString = receivingFiles.count > 1 ? LocalizablePeerToPeer.recipientFilesReceived.localized : LocalizablePeerToPeer.recipientFileReceived.localized
        let uploadedFilesString = String(format: fileString,  receivingFiles.count,formattedTotalUploaded, formattedTotalSize )
        
        self.progressViewModel?.percentTransferredText = percentUploadedInfo
        self.progressViewModel?.transferredFilesSummary = uploadedFilesString
        self.progressViewModel?.percentTransferred = Double(recipientPercentage)
        
        let progressFileItemVM = progressViewModel?.progressFileItems.first(where: {$0.file.id == file.file.id})
        
        let formattedFileUploaded = file.bytesReceived.getFormattedFileSize().getFileSizeWithoutUnit()
        let formattedFileTotalSize = (file.file.size ?? 0).getFormattedFileSize()
        let progression = "\(formattedFileUploaded)/\(formattedFileTotalSize)"
        
        progressFileItemVM?.transferSummary = progression
    }
    
    override func stopTask() {
        server.stopListening()
    }
    
    private func saveFiles() {
        
        guard let progressViewModel else {
            return
        }
        let addFolderFileResult = mainAppModel.vaultFilesManager?.addFolderFile(name: progressViewModel.title, parentId: nil)
        if case .success(let id) = addFolderFileResult {

        }
        self.isLoading = false
    }
}
