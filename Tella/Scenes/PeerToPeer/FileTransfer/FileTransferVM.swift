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
    case transferIsFinished
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
    
    var transferredFiles: [P2PTransferredFile] = []
    
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
    
    func initProgress(session: P2PSession) {
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
    
    func updateProgress(with file: P2PTransferredFile) {
        let totalBytesReceived = transferredFiles.reduce(0) { $0 + $1.bytesReceived }
        let totalBytes = transferredFiles.reduce(0) { $0 + ($1.file.size ?? 0) }
        
        guard totalBytes > 0 else { return }
        
        let ratio = Double(totalBytesReceived) / Double(totalBytes)
        if ratio <= 1 {
            progressViewModel?.percentTransferred = ratio
            progressViewModel?.percentTransferredText = formatPercentage(Int(ratio * 100))
            progressViewModel?.transferredFilesSummary = makeTransferredSummary(receivedBytes: totalBytesReceived, totalBytes: totalBytes)
            
            // Update individual file progress
            if let item = progressViewModel?.progressFileItems.first(where: { $0.vaultFile.id == file.vaultFile.id }) {
                let received = file.bytesReceived.getFormattedFileSize().getFileSizeWithoutUnit()
                let total = (file.file.size ?? 0).getFormattedFileSize()
                item.transferSummary = "\(received)/\(total)"
                item.p2pFileStatus = file.status
            }
        }
        
    }
    
    // MARK: - Helpers
    
    func makeTransferredSummary(receivedBytes: Int, totalBytes: Int) -> String {
        return ""
    }
    
    private func makeProgressItem(from file: P2PTransferredFile) -> ProgressFileItemViewModel {
        let size = (file.file.size ?? 0).getFormattedFileSize()
        let summary = "0/\(size)"
        return ProgressFileItemViewModel(
            vaultFile: file.vaultFile,
            transferSummary: summary,
            transferProgress: 0,
            p2pFileStatus: file.status
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

