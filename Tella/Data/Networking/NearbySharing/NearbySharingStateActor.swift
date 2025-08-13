//
//  NearbySharingStateActor.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/8/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Network
import Foundation

actor NearbySharingStateActor {
    
    // MARK: - Stored State
    
    var state = NearbySharingServerState()
    var pendingRegisterConnection: NWConnection?
    var pendingRegisterRequest: HTTPRequest?
    var pendingUploadConnection: NWConnection?
    
    // MARK: - General
    
    func currentSessionID() -> String? { state.session?.sessionId }
    func currentSession() -> NearbySharingSession? { state.session }

    func resetConnectionState() {
        state.reset()
        pendingRegisterConnection = nil
        pendingRegisterRequest = nil
        pendingUploadConnection = nil
    }
    
    func removeTempFiles() {
        let urls = state.session?.files.values.compactMap { $0.url } ?? []
        urls.forEach { $0.remove() }
    }
    
    // MARK: - Register
    
    func setPin(_ pin: String) { state.pin = pin }
    func pinMatches(_ pin: String) -> Bool { state.pin == pin }
    func markManualConnection() { state.isUsingManualConnection = true }
    func isManualConnection() -> Bool { state.isUsingManualConnection }
    
    func hasSession() -> Bool { state.session != nil }
    func tooManyAttempts() -> Bool { state.hasReachedMaxAttempts }
    func incrementFailedAttempts() { state.incrementFailedAttempts() }
    
    func createSessionAndReturnID() -> String {
        let session = NearbySharingSession(sessionId: UUID().uuidString)
        state.session = session
        return session.sessionId
    }
    
    func setPendingRegister(connection: NWConnection?, request: HTTPRequest?) {
        pendingRegisterConnection = connection
        pendingRegisterRequest = request
    }
    
    func getPendingRegister() -> (NWConnection, HTTPRequest)? {
        guard let connection = pendingRegisterConnection, let request = pendingRegisterRequest else { return nil }
        pendingRegisterConnection = nil
        pendingRegisterRequest = nil
        return (connection, request)
    }
    
    // MARK: - Prepare Upload
    
    func storePrepareUpload(_ request: PrepareUploadRequest) {
        state.session?.title = request.title
        request.files?.forEach { file in
            if let id = file.id {
                state.session?.files[id] = NearbySharingTransferredFile(file: file)
            }
        }
    }
    
    func setPendingUploadConnection(_ connection: NWConnection?) { pendingUploadConnection = connection }
    
    func getPendingUploadConnection() -> NWConnection? {
        defer { pendingUploadConnection = nil }
        return pendingUploadConnection
    }
    
    func assignTransmissionIDs() -> [(originalID: String?, transmissionID: String)] {
        var result: [(String?, String)] = []
        state.session?.files.forEach { fileID, fileInfo in
            let tid = UUID().uuidString
            state.session?.files[fileID]?.transmissionId = tid
            result.append((fileInfo.file.id, tid))
        }
        return result
    }
    
    // MARK: - Upload
    
    func fileInfo(for fileID: String) -> (transmissionID: String?, fileName: String?)? {
        guard let file = state.session?.files[fileID] else { return nil }
        return (file.transmissionId, file.file.fileName)
    }
    
    func markUploadFinished(fileID: String) {
        guard let file = state.session?.files[fileID] else { return }
        file.status = .finished
        state.session?.files[fileID] = file
    }
    
    @discardableResult
    func beginUpload(fileID: String, fileName: String) -> URL {
        let url = FileManager.tempDirectory(withFileName: fileName)
        if let file = state.session?.files[fileID] {
            file.status = .transferring
            file.url = url
            state.session?.files[fileID] = file
        }
        return url
    }
    
    func updateUploadProgress(fileID: String, bytes: Int) -> NearbySharingTransferredFile? {
        guard let file = state.session?.files[fileID] else { return nil }
        file.bytesReceived += bytes
        state.session?.files[fileID] = file
        return file
    }
    
    func markUploadFailed(fileID: String) {
        state.session?.files[fileID]?.status = .failed
    }
    
    func allTransfersCompleted() -> Bool {
        guard let files = state.session?.files else { return false }
        return files.values.first { $0.status == .transferring || $0.status == .queue } == nil
    }
}
