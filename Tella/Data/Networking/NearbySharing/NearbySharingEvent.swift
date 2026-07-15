//
//  NearbySharingEvent.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

/// Represents events and notifications from the NearbySharingEvent.
@MainActor
enum NearbySharingEvent {
    case serverStarted
    case serverStartFailed(Error?)
    case didRegister(success: Bool, manual: Bool)
    case receiverCertificateVerificationRequested // Received a ping; show receiver certificate hash to user.
    case senderCertificateVerificationRequested(certificateHash: String) // Register held; verify sender cert hash.
    case incompatibleProtocolVersion // v1 peer or unsupported protocol_version in QR.
    case prepareUploadReceived(files: [NearbySharingFile]?)
    case prepareUploadResponseSent(success: Bool)
    case connectionClosed
    case fileTransferProgress(NearbySharingTransferredFile)
    case errorOccured
}
