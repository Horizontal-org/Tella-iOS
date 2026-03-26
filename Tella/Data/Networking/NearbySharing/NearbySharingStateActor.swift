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
    var pendingRegisterResponse: Bool?
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
        pendingRegisterResponse = nil
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
    
    func getPendingRegisterResponse() -> Bool? {
        let response = pendingRegisterResponse
        pendingRegisterResponse = nil
        return response
    }
    
    func savePendingRegisterResponse(accept: Bool) {
        pendingRegisterResponse = accept
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
    
    func fileInfo(for fileID: String) -> NearbySharingTransferredFile? {
        guard let file = state.session?.files[fileID] else { return nil }
        return file
    }
    
    func markUploadFinished(fileID: String) {
        guard let file = state.session?.files[fileID] else { return }
        guard file.status == .transferring else { return }
        file.status = .finished
        state.session?.files[fileID] = file
    }

    /// Validates the upload request, checks storage, and returns the temp file URL to write into (like `finalizeUpload` for the completion path).
    func beginUploadFromRequest(_ request: HTTPRequest) throws -> URL {
        let uploadRequest: FileUploadRequest
        do {
            uploadRequest = try request.queryParameters.decode(FileUploadRequest.self)
        } catch {
            throw ServerStatus(code: .badRequest, message: .invalidRequestFormat)
        }

        guard let fileID = uploadRequest.fileID, !fileID.isEmpty,
              let transmissionID = uploadRequest.transmissionID, !transmissionID.isEmpty,
              let sessionID = uploadRequest.sessionID, !sessionID.isEmpty else {
            throw ServerStatus(code: .badRequest, message: .invalidRequestFormat)
        }

        guard sessionID == currentSessionID() else {
            throw ServerStatus(code: .unauthorized, message: .invalidSessionID)
        }

        guard let fileInfo = fileInfo(for: fileID),
              fileInfo.transmissionId == transmissionID,
              let fileType = fileInfo.file.fileType else {
            throw ServerStatus(code: .forbidden, message: .invalidTransmissionID)
        }

        if fileInfo.status == .finished {
            throw ServerStatus(code: .conflict, message: .transferAlreadyCompleted)
        }

        if let storageError = validateEnoughStorage(for: fileInfo.file) {
            throw storageError
        }

        guard let url = beginUpload(fileID: fileID, fileType: fileType) else {
            throw ServerStatus(code: .internalServerError, message: .serverError)
        }

        return url
    }

    func finalizeUpload(from request: HTTPRequest) async throws -> NearbySharingTransferredFile {
        let uploadRequest: FileUploadRequest

        do {
            uploadRequest = try request.queryParameters.decode(FileUploadRequest.self)
        } catch {
            throw ServerStatus(code: .badRequest, message: .invalidRequestFormat)
        }

        guard let fileID = uploadRequest.fileID, !fileID.isEmpty else {
            throw ServerStatus(code: .badRequest, message: .invalidRequestFormat)
        }
        
        guard let file = fileInfo(for: fileID) else {
            throw ServerStatus(code: .notFound, message: .transferNotFound)
        }

        if file.status == .finished {
            throw ServerStatus(code: .conflict, message: .transferAlreadyCompleted)
        }

        guard let fileURL = file.url else {
            throw ServerStatus(code: .notFound, message: .transferNotFound)
        }

        guard let expectedHash = file.file.sha256, !expectedHash.isEmpty else {
            throw failUpload(fileID: fileID, fileURL: fileURL)
        }

        guard let computedHash = await fileURL.sha256Hash(),
              computedHash.caseInsensitiveCompare(expectedHash) == .orderedSame else {
            throw failUpload(fileID: fileID, fileURL: fileURL)
        }

        markUploadFinished(fileID: fileID)
        return file
    }
        
    private func failUpload(fileID: String, fileURL: URL) -> ServerStatus {
        state.session?.files[fileID]?.status = .failed
        fileURL.remove()
        return ServerStatus(code: .notAcceptable, message: .fileHashMismatch)
    }
    
    @discardableResult
    func beginUpload(fileID: String, fileType: String) -> URL? {
        let fileName = UUID().uuidString + "." + (fileType.fileExtensionFromMimeType() ?? "")
        let url = FileManager.tempDirectory(withFileName: fileName)
        guard let file = state.session?.files[fileID],
              file.status == .queue
        else {
            return nil
        }
        file.status = .transferring
        file.url = url
        state.session?.files[fileID] = file
        return url
    }
    
    func updateUploadProgress(fileID: String, bytes: Int) -> NearbySharingTransferredFile? {
        guard let file = state.session?.files[fileID] else { return nil }
        guard file.status == .transferring else { return nil }
        
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

    private func validateEnoughStorage(for file: NearbySharingFile) -> ServerStatus? {
        guard let size = file.size, size > 0 else {
            return ServerStatus(code: .badRequest, message: .invalidRequestFormat)
        }

        let availableSpace = FileManager.default.availableDiskSpace

        let safetyMargin: Int64 = 10 * 1024 * 1024
        let requiredSpace = (Int64(size) * 2) + safetyMargin

        guard availableSpace >= requiredSpace else {
            return ServerStatus(code: .insufficientStorage, message: .insufficientStorage)
        }

        return nil
    }
}
