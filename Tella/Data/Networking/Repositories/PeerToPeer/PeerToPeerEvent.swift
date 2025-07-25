//
//  PeerToPeerEvent.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

/// Represents events and notifications from the PeerToPeerServer.
enum PeerToPeerEvent {
    case serverStartFailed(Error?)
    case didRegister(success: Bool, manual: Bool)
    case registrationRequested         // A client has requested to register (manual confirmation needed).
    case verificationRequested         // Received a ping; show verification hash to user.
    case prepareUploadReceived(files: [P2PFile]?)
    case prepareUploadResponseSent(success: Bool)
    case connectionClosed
    case fileTransferProgress(P2PTransferredFile)
    case allTransfersCompleted
}
