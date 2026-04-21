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
    
    /// Wrong-PIN attempts per registration nonce
    private var registerPinFailuresByNonce: [String: Int] = [:]
    private let maxFailedAttempts = 3
    private let transferNonceManager = NonceManager()
    
    // MARK: - General
    
    func currentSessionID() -> String? { state.session?.sessionId }
    func currentSession() -> NearbySharingSession? { state.session }
    
    func resetConnectionState() {
        state.reset()
        pendingRegisterConnection = nil
        pendingRegisterRequest = nil
        pendingUploadConnection = nil
        pendingRegisterResponse = nil
        registerPinFailuresByNonce.removeAll()
        transferNonceManager.removeAll()
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
    
    private func registerPinFailureCount(for nonce: String) -> Int {
        registerPinFailuresByNonce[nonce, default: 0]
    }

    func hasReachedMaxAttempts(for nonce: String) -> Bool {
        registerPinFailureCount(for: nonce) >= maxFailedAttempts
    }
    
    func recordRegisterPinFailure(for nonce: String) {
        registerPinFailuresByNonce[nonce, default: 0] += 1
    }
    
    /// Registers a transfer nonce via `NonceManager.add`. Returns `nil` on success, otherwise an error for the HTTP response.
    func addTransferNonce(_ nonce: String?) -> NonceManager.NonceError? {
        guard let nonce else { return .zeroLength }
        do {
            try transferNonceManager.add(nonce)
            return nil
        } catch let error as NonceManager.NonceError {
            return error
        } catch {
            return .zeroLength
        }
    }
    
    func createSessionAndReturnID(registrationNonce: String) -> String {
        registerPinFailuresByNonce.removeValue(forKey: registrationNonce)
        let session = NearbySharingSession(sessionId: UUID().uuidString, registrationNonce: registrationNonce)
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

    /// Recipient: `NearbySharingTransferLimits.validatePrepareFiles` plus free disk for the full declared batch (prepare-upload).
    func validateRecipientPrepareUpload(_ files: [NearbySharingFile]?) -> ServerStatus? {
        if let error = NearbySharingTransferLimits.validatePrepareFiles(files, config: .standard) { return error }
        return NearbySharingTransferStorageValidation.validateStorageAgainstLocalDisk(files)
    }
    
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
        
        if let nonceError = addTransferNonce(uploadRequest.nonce) {
            throw nonceError.serverStatus
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

    func finalizeUpload(from request: HTTPRequest) async -> FinalizeUploadOutcome {
        let uploadRequest: FileUploadRequest
        do {
            uploadRequest = try request.queryParameters.decode(FileUploadRequest.self)
        } catch {
            return .failure(ServerStatus(code: .badRequest, message: .invalidRequestFormat), file: nil)
        }

        guard let fileID = uploadRequest.fileID, !fileID.isEmpty else {
            return .failure(ServerStatus(code: .badRequest, message: .invalidRequestFormat), file: nil)
        }

        guard let file = fileInfo(for: fileID) else {
            return .failure(ServerStatus(code: .notFound, message: .transferNotFound), file: nil)
        }

        if file.status == .finished {
            return .failure(
                ServerStatus(code: .conflict, message: .transferAlreadyCompleted),
                file: fileInfo(for: fileID)
            )
        }

        guard let fileURL = file.url else {
            markUploadFailed(fileID: fileID)
            return .failure(
                ServerStatus(code: .notFound, message: .transferNotFound),
                file: fileInfo(for: fileID)
            )
        }

        guard let expectedHash = file.file.sha256, !expectedHash.isEmpty else {
            let status = failUpload(fileID: fileID, fileURL: fileURL)
            return .failure(status, file: fileInfo(for: fileID))
        }

        guard let computedHash = await fileURL.sha256Hash(),
              computedHash.caseInsensitiveCompare(expectedHash) == .orderedSame else {
            let status = failUpload(fileID: fileID, fileURL: fileURL)
            return .failure(status, file: fileInfo(for: fileID))
        }

        markUploadFinished(fileID: fileID)
        return .success(file)
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

    private func validateEnoughStorage(for file: NearbySharingFile) -> ServerStatus? {
        guard let size = file.size, size > 0 else {
            return ServerStatus(code: .badRequest, message: .invalidRequestFormat)
        }
        return NearbySharingTransferStorageValidation.validateStorage(forContentSizeBytes: Int64(size))
    }
}
