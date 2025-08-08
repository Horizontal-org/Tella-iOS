//
//  NearbySharingResultVM.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 15/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Combine

final class NearbySharingResultVM: ObservableObject {
    
    let transferredFiles: [NearbySharingTransferredFile]
    let participant: NearbySharingParticipant
    
    init(transferredFiles: [NearbySharingTransferredFile], participant: NearbySharingParticipant) {
        self.transferredFiles = transferredFiles
        self.participant = participant
    }
    
    // MARK: - Computed Properties
    
    private var successStatus: NearbySharingFileStatus {
        participant == .recipient ? .saved : .finished
    }
    
    private var successSingle: LocalizableDelegate {
        participant == .recipient ? LocalizableNearbySharing.successFileReceivedExpl : LocalizableNearbySharing.successFileSentExpl
    }
    
    private var successMultiple: LocalizableDelegate {
        participant == .recipient ? LocalizableNearbySharing.successFilesReceivedExpl : LocalizableNearbySharing.successFilesSentExpl
    }
    
    private var failureSingle: LocalizableDelegate {
        LocalizableNearbySharing.failureFileReceivedExpl
    }
    
    private var failureMultiple: LocalizableDelegate {
        LocalizableNearbySharing.failureFilesReceivedExpl
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
        allFilesTransferred ? LocalizableNearbySharing.successTitle.localized : LocalizableNearbySharing.failureTitle.localized
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
                format = LocalizableNearbySharing.fileReceivedFileNotReceivedExpl.localized
            case (1, _):
                format = LocalizableNearbySharing.fileReceivedFilesNotReceivedExpl.localized
            case (_, 1):
                format = LocalizableNearbySharing.filesReceivedFileNotReceivedExpl.localized
            default:
                format = LocalizableNearbySharing.filesReceivedFilesNotReceivedExpl.localized
            }
            return String(format: format, successCount, failureCount)
        }
    }
    
    var buttonTitle: String? {
        (noFilesTransferred || participant == .sender) ? nil : LocalizableNearbySharing.viewFilesAction.localized
    }
}
