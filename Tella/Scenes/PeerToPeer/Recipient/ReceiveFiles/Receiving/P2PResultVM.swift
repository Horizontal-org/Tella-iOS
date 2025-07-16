//
//  P2PResultVM.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 15/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Combine

final class P2PResultVM: ObservableObject {
    
    let transferredFiles: [P2PTransferredFile]
    let participant: PeerToPeerParticipant
    
    init(transferredFiles: [P2PTransferredFile], participant: PeerToPeerParticipant) {
        self.transferredFiles = transferredFiles
        self.participant = participant
    }
    
    // MARK: - Computed Properties
    
    private var successStatus: P2PFileStatus {
        participant == .recipient ? .saved : .finished
    }
    
    private var successSingle: LocalizableDelegate {
        participant == .recipient ? LocalizablePeerToPeer.successFileReceivedExpl : LocalizablePeerToPeer.successFileSentExpl
    }
    
    private var successMultiple: LocalizableDelegate {
        participant == .recipient ? LocalizablePeerToPeer.successFilesReceivedExpl : LocalizablePeerToPeer.successFilesSentExpl
    }
    
    private var failureSingle: LocalizableDelegate {
        LocalizablePeerToPeer.failureFileReceivedExpl
    }
    
    private var failureMultiple: LocalizableDelegate {
        LocalizablePeerToPeer.failureFilesReceivedExpl
    }
    
    var allFilesTransferred: Bool {
        transferredFiles.allSatisfy { $0.status == successStatus }
    }
    
    var noFilesTransferred: Bool {
        transferredFiles.allSatisfy { $0.status != successStatus }
    }
    
    var imageName: String {
        allFilesTransferred ? "checked-circle" : "warning"
    }
    
    var title: String {
        allFilesTransferred ? LocalizablePeerToPeer.successTitle.localized : LocalizablePeerToPeer.failureTitle.localized
    }
    
    var subTitle: String {
        let total = transferredFiles.count
        let successCount = transferredFiles.filter { $0.status == successStatus }.count
        let failureCount = total - successCount
        
        switch (successCount, failureCount) {
        case (let success, 0) where success == total:
            let format = total == 1 ? successSingle.localized : successMultiple.localized
            return String(format: format, total)
            
        case (0, let failure) where failure == total:
            let format = total == 1 ? failureSingle.localized : failureMultiple.localized
            return String(format: format, total)
            
        default:
            let format: String
            switch (successCount, failureCount) {
            case (1, 1):
                format = LocalizablePeerToPeer.fileReceivedFileNotReceivedExpl.localized
            case (1, _):
                format = LocalizablePeerToPeer.fileReceivedFilesNotReceivedExpl.localized
            case (_, 1):
                format = LocalizablePeerToPeer.filesReceivedFileNotReceivedExpl.localized
            default:
                format = LocalizablePeerToPeer.filesReceivedFilesNotReceivedExpl.localized
            }
            return String(format: format, successCount, failureCount)
        }
    }
    
    var buttonTitle: String? {
        noFilesTransferred ? nil : LocalizablePeerToPeer.viewFilesAction.localized
    }
}
