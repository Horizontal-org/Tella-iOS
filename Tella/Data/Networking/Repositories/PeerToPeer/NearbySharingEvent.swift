//
//  NearbySharingEvent.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

/// Represents events and notifications from the NearbySharingEvent.
enum NearbySharingEvent {
    case serverStarted
    case serverStartFailed(Error?)
    case didRegister(success: Bool, manual: Bool)
    case registrationRequested         // A client has requested to register (manual confirmation needed).
    case verificationRequested         // Received a ping; show verification hash to user.
    case prepareUploadReceived(files: [NearbySharingFile]?)
    case prepareUploadResponseSent(success: Bool)
    case connectionClosed
    case fileTransferProgress(NearbySharingTransferredFile)
    case allTransfersCompleted
    case errorOccured

}
