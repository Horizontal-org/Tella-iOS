//
//  FileTransferVM.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 7/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Combine

enum TransferViewAction: Equatable {
    case none
    case shouldShowResults
}

class FileTransferVM: ObservableObject {
    
    var mainAppModel: MainAppModel
    
    @Published var progressViewModel : ProgressViewModel?
    @Published var isLoading: Bool = false
    @Published var viewAction: TransferViewAction = .none
    
    var title: String
    var bottomSheetTitle: String
    var bottomSheetMessage: String
    
    var transferredFiles: [NearbySharingTransferredFile] = []
    
    init(mainAppModel: MainAppModel,
         title: String,
         bottomSheetTitle: String,
         bottomSheetMessage: String) {
        
        self.mainAppModel = mainAppModel
        self.title = title
        self.bottomSheetTitle = bottomSheetTitle
        self.bottomSheetMessage = bottomSheetMessage
        self.bottomSheetMessage = bottomSheetMessage
    }
    
    func initProgress(session: NearbySharingSession) {
        let title = session.title ?? ""
        let totalSize = transferredFiles.reduce(0) { $0 + ($1.file.size ?? 0) }
        let progressItems = transferredFiles.map(makeProgressItem)
        
        progressViewModel = ProgressViewModel(
            title: title,
            percentTransferredText: formatPercentage(0),
            transferredFilesSummary: makeTransferredSummary(receivedBytes: 0, totalBytes: totalSize),
            percentTransferred: 0,
            progressFileItems: progressItems
        )
    }
    
    func updateProgress(with file: NearbySharingTransferredFile) {
        Task {
            let totalBytesReceived = transferredFiles.reduce(0) { $0 + $1.bytesReceived }
            let totalBytes = transferredFiles.reduce(0) { $0 + ($1.file.size ?? 0) }
            
            guard totalBytes > 0 else { return }
            
            let ratio = Double(totalBytesReceived) / Double(totalBytes)
            guard ratio <= 1 else { return }
            
            let percentText = formatPercentage(Int(ratio * 100))
            let summaryText = makeTransferredSummary(
                receivedBytes: totalBytesReceived,
                totalBytes: totalBytes
            )
            
            let itemToUpdate = progressViewModel?.progressFileItems.first(where: {
                $0.vaultFile.id == file.vaultFile.id
            })
            
            let receivedFormatted = file.bytesReceived.getFormattedFileSize().getFileSizeWithoutUnit()
            let totalFormatted = (file.file.size ?? 0).getFormattedFileSize()
            let newTransferSummary = "\(receivedFormatted)/\(totalFormatted)"
            
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                
                self.progressViewModel?.percentTransferred = ratio
                self.progressViewModel?.percentTransferredText = percentText
                self.progressViewModel?.transferredFilesSummary = summaryText
                
                if let item = itemToUpdate {
                    item.transferSummary = newTransferSummary
                    item.fileStatus = file.status
                }
            }
        }
    }
    func updateStatus(with file: NearbySharingTransferredFile) {
        Task {
            let itemToUpdate = progressViewModel?.progressFileItems.first(where: {
                $0.vaultFile.id == file.vaultFile.id
            })
            
            if let item = itemToUpdate {
                await MainActor.run {
                    item.fileStatus = file.status
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func makeTransferredSummary(receivedBytes: Int, totalBytes: Int) -> String {
        return ""
    }
    
    private func makeProgressItem(from file: NearbySharingTransferredFile) -> ProgressFileItemViewModel {
        let size = (file.file.size ?? 0).getFormattedFileSize()
        let summary = "0/\(size)"
        return ProgressFileItemViewModel(
            vaultFile: file.vaultFile,
            transferSummary: summary,
            transferProgress: 0,
            fileStatus: file.status
        )
    }
    
    func formatPercentage(_ percent: Int) -> String {
        return ""
    }
    
    func stopTask() {
        
    }
}

extension FileTransferVM {
    static func stub() -> FileTransferVM {
        return FileTransferVM(mainAppModel: MainAppModel.stub(), title: "Title", bottomSheetTitle: "Title", bottomSheetMessage: "Message")
    }
}



