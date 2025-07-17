//
//  P2PServerState.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 23/6/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

final class P2PServerState {
    
    var pin: String?
    var session: P2PSession?
    var isUsingManualConnection: Bool
    
    private(set) var failedAttempts: Int
    private let maxFailedAttempts = 3
    
    var hasReachedMaxAttempts: Bool {
        return failedAttempts >= maxFailedAttempts
    }
    
    init(pin: String? = nil,
         session: P2PSession? = nil,
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

final class P2PSession {
    
    let sessionId: String
    var status: SessionStatus
    var title: String?
    var files: [String: P2PTransferredFile]
    
    init(sessionId: String,
         status: SessionStatus = .waiting,
         files: [String: P2PTransferredFile] = [:],
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

final class P2PTransferredFile: Codable {
    
    var file: P2PFile
    var vaultFile: VaultFileDB
    var status: P2PFileStatus
    var transmissionId: String?
    var url: URL?
    var bytesReceived: Int = 0
    
    init(file: P2PFile,
         status: P2PFileStatus = .queue,
         transmissionId: String? = nil,
         url: URL? = nil,
         bytesReceived: Int = 0) {
        self.file = file
        self.vaultFile =  VaultFileDB(p2pFile: file)
        self.status = status
        self.transmissionId = transmissionId
        self.url = url
        self.bytesReceived = bytesReceived
    }
    
    init(vaultFile: VaultFileDB,
         status: P2PFileStatus = .queue,
         transmissionId: String? = nil,
         url: URL? = nil,
         bytesReceived: Int64 = 0) {
        self.vaultFile = vaultFile
        self.file = P2PFile(vaultFile: vaultFile)
        self.status = status
        self.transmissionId = transmissionId
        self.url = url
        self.bytesReceived = Int(bytesReceived)
    }
    
}

enum P2PFileStatus: String, Codable {
    case queue
    case transferring
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
