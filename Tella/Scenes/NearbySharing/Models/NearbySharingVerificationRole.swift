//
//  NearbySharingVerificationRole.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 12/6/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

enum NearbySharingVerificationRole {
    /// Receiver (server) certificate hash after ping
    case receiverHash(confirmAction: VerificationConfirmAction)
    /// Sender (client) certificate hash after register
    case senderHash(confirmAction: VerificationConfirmAction)
    
    enum VerificationConfirmAction {
        case sendRegister
        case acceptPendingRegistration
        case acknowledgeOnly
        /// Recipient confirmed receiver hash; server branches on whether sender cert is pre-pinned.
        case confirmReceiverHash
    }
    
    /// "Step 1: Confirm sender hash"
    func stepTitle(participant: NearbySharingParticipant) -> String {
        switch (participant, self) {
        case (.sender, .receiverHash):
            return LocalizableNearbySharing.verificationStep1ConfirmRecipientHash.localized
        case (.sender, .senderHash):
            return LocalizableNearbySharing.verificationStep2ConfirmSenderHash.localized
        case (.recipient, .senderHash):
            return LocalizableNearbySharing.verificationStep2ConfirmSenderHash.localized
        case (.recipient, .receiverHash):
            return LocalizableNearbySharing.verificationStep1ConfirmRecipientHash.localized
        }
    }
    
    /// "Confirm and connect" or "Confirm and continue"
    func isFinalStep(participant: NearbySharingParticipant) -> Bool {
        switch (participant, self) {
        case (.sender, .senderHash), (.recipient, .senderHash):
            return true
        case (.sender, .receiverHash), (.recipient, .receiverHash):
            return false
        }
    }
}
