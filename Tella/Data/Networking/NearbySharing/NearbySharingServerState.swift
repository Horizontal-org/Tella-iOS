//
//  NearbySharingServerState.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 23/6/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

final class NearbySharingServerState {
    
    var pin: String?
    var session: NearbySharingSession?
    var isUsingManualConnection: Bool
    
    private(set) var failedAttempts: Int
    private let maxFailedAttempts = 3
    
    var hasReachedMaxAttempts: Bool {
        return failedAttempts >= maxFailedAttempts
    }
    
    init(pin: String? = nil,
         session: NearbySharingSession? = nil,
         failedAttempts: Int = 0,
         isUsingManualConnection: Bool = false) {
        self.pin = pin
        self.session = session
        self.failedAttempts = failedAttempts
        self.isUsingManualConnection = isUsingManualConnection
    }
    
    func incrementFailedAttempts() {
        failedAttempts += 1
    }
    
    func reset() {
        pin = nil
        session = nil
        failedAttempts = 0
        isUsingManualConnection = false
    }
}

final class NearbySharingSession {
    
    let sessionId: String
    var status: SessionStatus
    var title: String?
    var files: [String: NearbySharingTransferredFile]
    
    init(sessionId: String,
         status: SessionStatus = .waiting,
         files: [String: NearbySharingTransferredFile] = [:],
         title: String? = nil) {
        self.sessionId = sessionId
        self.status = status
        self.files = files
        self.title = title
    }
    
    var isActive: Bool {
        return status == .waiting || status == .sending
    }
    
    var hasFiles: Bool {
        return !files.isEmpty
    }
}

final class NearbySharingTransferredFile: Codable {
    
    var file: NearbySharingFile
    var vaultFile: VaultFileDB
    var status: NearbySharingFileStatus
    var transmissionId: String?
    var url: URL?
    var bytesReceived: Int = 0
    
    init(file: NearbySharingFile,
         status: NearbySharingFileStatus = .queue,
         transmissionId: String? = nil,
         url: URL? = nil,
         bytesReceived: Int = 0) {
        self.file = file
        self.vaultFile =  VaultFileDB(file: file)
        self.status = status
        self.transmissionId = transmissionId
        self.url = url
        self.bytesReceived = bytesReceived
    }
    
    init(vaultFile: VaultFileDB,
         status: NearbySharingFileStatus = .queue,
         transmissionId: String? = nil,
         url: URL? = nil,
         bytesReceived: Int64 = 0) {
        self.vaultFile = vaultFile
        self.file = NearbySharingFile(vaultFile: vaultFile)
        self.status = status
        self.transmissionId = transmissionId
        self.url = url
        self.bytesReceived = Int(bytesReceived)
    }
}

enum NearbySharingFileStatus: String, Codable {
    case queue
    case transferring
    case saving
    case failed
    case finished
    case saved
}

enum SessionStatus: String, Codable {
    case waiting
    case sending
    case finished
    case finishedWithErrors
}
