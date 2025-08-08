//
//  NearbySharingServer.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Network
import Combine
import Foundation

// MARK: - Handler Protocols

protocol PingHandler {
    func handlePingRequest(on connection: NWConnection)
}

protocol RegisterHandler {
    func handleRegisterRequest(on connection: NWConnection, request: HTTPRequest)
    func generateRegisterServerResponse(from request: HTTPRequest) throws -> NearbySharingServerResponse
    func respondToRegistrationRequest(accept: Bool)
}

protocol PrepareUploadHandler {
    func handlePrepareUploadRequest(on connection: NWConnection, request: HTTPRequest)
    func respondToFileOffer(accept: Bool)
}

protocol UploadHandler {
    func handleFileUploadRequest(on connection: NWConnection, request: HTTPRequest) async -> URL?
    func processProgress(connection: NWConnection, bytesReceived: Int, for request: HTTPRequest)
}

protocol CloseConnectionHandler {
    func handleCloseConnectionRequest(on connection: NWConnection, request: HTTPRequest)
    func generateCloseConnectionResponse(from requestBody: String) throws -> NearbySharingServerResponse
}

// MARK: - Main Server Class

final class NearbySharingServer {
    
    // MARK: - Properties
    
    private let networkManager = NetworkManager()
    private(set) var serverState = NearbySharingServerState()
    
    /// Single Combine publisher for all server events.
    var eventPublisher = PassthroughSubject<NearbySharingEvent, Never>()
    
    // Stored context for pending user decisions
    private var pendingRegisterConnection: NWConnection?
    private var pendingRegisterRequest: HTTPRequest?
    private var pendingUploadConnection: NWConnection?
    
    init() {
        networkManager.delegate = self
    }
    
    // MARK: - Server Lifecycle
    
    func startListening(port: Int, pin: String, clientIdentity: SecIdentity) {
        serverState.pin = pin
        networkManager.startListening(port: port, clientIdentity: clientIdentity)
    }
    
    func stopServer() {
        networkManager.stopListening()
    }
    
    func resetServerState() {
        stopServer()
        resetConnectionState()
    }
    
    func resetFullServerState() {
        stopServer()
        cleanServer()
    }

    func cleanServer() {
        networkManager.cleanConnections()
        removeTempFiles()
        resetConnectionState()
    }
    
    private func removeTempFiles() {
        guard let fileURLs = serverState.session?.files.values.compactMap({ $0.url }) else { return }
        fileURLs.forEach { $0.remove() }
    }
    
    private func resetConnectionState() {
        serverState.reset()
        pendingRegisterConnection = nil
        pendingRegisterRequest = nil
        pendingUploadConnection = nil
        eventPublisher = PassthroughSubject<NearbySharingEvent, Never>()
    }
    
    // MARK: - Response Helpers
    
    private func createErrorResponse(_ status: HTTPStatusCode, endpoint: NearbySharingEndpoint? = nil) -> NearbySharingServerResponse {
        let errorPayload = ErrorMessage(error: status.reasonPhrase)
        let responseData = HTTPResponseBuilder(status: status)
            .setContentType(.json)
            .setBody(errorPayload)
            .closeConnection()
            .build()
        return NearbySharingServerResponse(dataResponse: responseData, response: .failure, endpoint: endpoint)
    }
    
    private func sendSuccessResponse(connection: NWConnection, endpoint: NearbySharingEndpoint) {
        let payload = BoolResponse(success: true)
        guard let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(payload)
            .closeConnection()
            .build() else {
            sendInternalServerError(connection: connection)
            return
        }
        let response = NearbySharingServerResponse(dataResponse: responseData, response: .success, endpoint: endpoint)
        sendData(connection: connection, serverResponse: response)
    }
    
    private func sendResponse(connection: NWConnection, serverResponse: NearbySharingServerResponse?) {
        guard let response = serverResponse else {
            sendInternalServerError(connection: connection)
            return
        }
        sendData(connection: connection, serverResponse: response)
    }
    
    private func sendInternalServerError(connection: NWConnection) {
        let errorResponse = createErrorResponse(.internalServerError)
        sendData(connection: connection, serverResponse: errorResponse)
    }
    
    private func sendData(connection: NWConnection, serverResponse: NearbySharingServerResponse) {
        guard let data = serverResponse.dataResponse else {
            debugLog("No data to send for response.")
            eventPublisher.send(.errorOccured)
            return
        }
        
        Task {
            do {
                try await networkManager.sendData(to: connection, data: data)
                handleResponseSent(serverResponse)
            } catch {
                debugLog("Failed to send response data: \(error)")
                eventPublisher.send(.errorOccured)
            }
        }
    }
    
    private func handleResponseSent(_ serverResponse: NearbySharingServerResponse) {
        guard let endpoint = serverResponse.endpoint else {
            eventPublisher.send(.errorOccured)
            return
        }
        let success = (serverResponse.response == .success)
        
        switch endpoint {
        case .register:
            eventPublisher.send(.didRegister(success: success, manual: serverState.isUsingManualConnection))
        case .prepareUpload:
            eventPublisher.send(.prepareUploadResponseSent(success: success))
        case .closeConnection:
            eventPublisher.send(.connectionClosed)
            resetServerState()
        case .upload, .ping:
            break
        }
    }
    
    private func handleError(for request: HTTPRequest?, on connection: NWConnection) {
        guard let req = request,
              let endpoint = NearbySharingEndpoint(rawValue: req.endpoint) else {
            return
        }
        
        if endpoint == .upload {
            handleUploadFailure(connection: connection, request: req)
        } else {
            sendInternalServerError(connection: connection)
        }
    }
    
    // MARK: - Request Processing
    
    /// Process a completed HTTP request (headers and full body if applicable).
    private func processRequest(connection: NWConnection, httpRequest: HTTPRequest) {
        guard let endpoint = NearbySharingEndpoint(rawValue: httpRequest.endpoint) else {
            debugLog("Received request for unknown endpoint")
            return
        }
        
        switch endpoint {
        case .ping:
            handlePingRequest(on: connection)
        case .register:
            handleRegisterRequest(on: connection, request: httpRequest)
        case .prepareUpload:
            handlePrepareUploadRequest(on: connection, request: httpRequest)
        case .upload:
            Task {
                await handleFileUploadRequest(on: connection, request: httpRequest)
            }
        case .closeConnection:
            handleCloseConnectionRequest(on: connection, request: httpRequest)
        }
    }
}

// MARK: - NetworkManagerDelegate

extension NearbySharingServer: NetworkManagerDelegate {
    
    func networkManagerDidStartListening() {
        debugLog("Server is now listening on the specified port.")
        eventPublisher.send(.serverStarted)
    }
    
    func networkManager(didFailWithListener error: Error?) {
        debugLog("Server failed to start")
        eventPublisher.send(.serverStartFailed(error))
    }
    
    func networkManager(didFailWith error: Error?, context: ConnectionContext?) {
        // Handle connection/request failure
        guard let context else { return  }
        handleError(for: context.request, on: context.connection)
    }
    
    func networkManager(didReceiveCompleteRequest context: ConnectionContext) {
        // Received a full request (possibly with body fully read)
        processRequest(connection: context.connection, httpRequest: context.request)
    }
    
    func networkManager(verifyParametersFor context: ConnectionContext) async -> URL? {
        guard context.request.endpoint == NearbySharingEndpoint.upload.rawValue else {
            return nil
        }
        
        return await handleFileUploadRequest(on: context.connection, request: context.request)
    }
    
    func networkManager(didReceive bytes: Int, for context: ConnectionContext) {
        // Received a chunk of data for an ongoing upload
        processProgress(connection: context.connection, bytesReceived: bytes, for: context.request)
    }
}
// MARK: - PingHandler Implementation

extension NearbySharingServer: PingHandler {
    func handlePingRequest(on connection: NWConnection) {
        // A ping indicates a new manual connection attempt.
        eventPublisher.send(.verificationRequested)
        serverState.isUsingManualConnection = true
        // Respond to the ping with success (to acknowledge).
        sendSuccessResponse(connection: connection, endpoint: .ping)
    }
}

// MARK: - RegisterHandler Implementation

extension NearbySharingServer: RegisterHandler {
    func handleRegisterRequest(on connection: NWConnection, request: HTTPRequest) {
        if serverState.isUsingManualConnection {
            // Manual mode: store the request and ask the user for confirmation.
            pendingRegisterConnection = connection
            pendingRegisterRequest = request
            eventPublisher.send(.registrationRequested)
        } else {
            // Automatic mode: process registration immediately.
            acceptRegisterRequest(connection: connection, httpRequest: request)
        }
    }
    
    func generateRegisterServerResponse(from request: HTTPRequest) throws -> NearbySharingServerResponse {
        // Ensure no active session exists
        if serverState.session != nil {
            throw HTTPStatusCode.conflict  // Already a session in progress
        }
        if serverState.hasReachedMaxAttempts {
            throw HTTPStatusCode.tooManyRequests
        }
        // Decode the registration request body (expects a PIN)
        guard let regReq = request.body.decodeJSON(RegisterRequest.self) else {
            throw HTTPStatusCode.badRequest
        }
        // Verify the PIN
        if serverState.pin != regReq.pin {
            serverState.incrementFailedAttempts()
            if serverState.hasReachedMaxAttempts {
                throw HTTPStatusCode.tooManyRequests
            }
            throw HTTPStatusCode.unauthorized
        }
        // PIN is correct, reset failed attempts and create a session
        serverState.session = NearbySharingSession(sessionId: UUID().uuidString)
        // Build a success response with the new session ID
        let payload = RegisterResponse(sessionId: serverState.session!.sessionId)
        guard let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(payload)
            .closeConnection()
            .build() else {
            throw HTTPStatusCode.internalServerError
        }
        return NearbySharingServerResponse(dataResponse: responseData, response: .success, endpoint: .register)
    }
    
    /// Call this to respond to a pending registration request (from a `.registrationRequested` event).
    func respondToRegistrationRequest(accept: Bool) {
        guard let connection = pendingRegisterConnection,
              let request = pendingRegisterRequest else { return } // No pending request to respond to
        
        if accept {
            acceptRegisterRequest(connection: connection, httpRequest: request)
        } else {
            discardRegisterRequest(connection: connection)
        }
        // Clear the pending request after responding
        pendingRegisterConnection = nil
        pendingRegisterRequest = nil
    }
    
    
    private func acceptRegisterRequest(connection: NWConnection, httpRequest: HTTPRequest) {
        do {
            let serverResponse = try generateRegisterServerResponse(from: httpRequest)
            sendResponse(connection: connection, serverResponse: serverResponse)
        } catch let statusError as HTTPStatusCode {
            sendResponse(connection: connection, serverResponse: createErrorResponse(statusError))
        } catch {
            sendInternalServerError(connection: connection)
        }
    }
    
    private func discardRegisterRequest(connection: NWConnection) {
        sendResponse(connection: connection, serverResponse: createErrorResponse(.unauthorized))
    }
}

// MARK: - PrepareUploadHandler Implementation

extension NearbySharingServer: PrepareUploadHandler {
    
    func handlePrepareUploadRequest(on connection: NWConnection, request: HTTPRequest) {
        guard let prepReq = request.body.decodeJSON(PrepareUploadRequest.self) else {
            sendResponse(connection: connection, serverResponse: createErrorResponse(.badRequest))
            return
        }
        guard prepReq.sessionID == serverState.session?.sessionId else {
            sendResponse(connection: connection, serverResponse: createErrorResponse(.unauthorized))
            return
        }
        // Store metadata about the files to be uploaded
        serverState.session?.title = prepReq.title
        prepReq.files?.forEach { file in
            if let fileId = file.id {
                serverState.session?.files[fileId] = NearbySharingTransferredFile(file: file)
            }
        }
        // Save the connection and notify the UI about incoming files
        pendingUploadConnection = connection
        eventPublisher.send(.prepareUploadReceived(files: prepReq.files))
    }
    
    /// Call this to respond to a pending file upload offer (from a `.prepareUploadReceived` event).
    func respondToFileOffer(accept: Bool) {
        guard let connection = pendingUploadConnection else { return } // No pending file offer to respond to
        sendPrepareUploadResponse(connection: connection, accept: accept)
        pendingUploadConnection = nil
    }
    
    private func createAcceptUploadResponse() -> NearbySharingServerResponse {
        var filesResponse: [NearbySharingFileResponse] = []
        serverState.session?.files.forEach { (fileID, fileInfo) in
            let transmissionId = UUID().uuidString
            serverState.session?.files[fileID]?.transmissionId = transmissionId
            filesResponse.append(NearbySharingFileResponse(id: fileInfo.file.id, transmissionID: transmissionId))
        }
        
        let payload = PrepareUploadResponse(files: filesResponse)
        guard let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(payload)
            .closeConnection()
            .build() else {
            return createErrorResponse(.internalServerError)
        }
        
        return NearbySharingServerResponse(dataResponse: responseData, response: .success, endpoint: .prepareUpload)
    }
    
    private func sendPrepareUploadResponse(connection: NWConnection, accept: Bool) {
        let response = accept ? createAcceptUploadResponse() : createRejectUploadResponse()
        sendResponse(connection: connection, serverResponse: response)
    }
    
    private func createRejectUploadResponse() -> NearbySharingServerResponse {
        return createErrorResponse(.forbidden, endpoint: .prepareUpload)
    }
}

// MARK: - UploadHandler Implementation

extension NearbySharingServer: UploadHandler {
    
    func handleFileUploadRequest(on connection: NWConnection, request: HTTPRequest) async -> URL? {
        do {
            let uploadReq: FileUploadRequest = try request.queryParameters.decode(FileUploadRequest.self)
            guard let fileID = uploadReq.fileID,
                  let transmissionID = uploadReq.transmissionID,
                  let sessionID = uploadReq.sessionID else {
                sendResponse(connection: connection, serverResponse: createErrorResponse(.badRequest))
                return nil
            }
            // Validate session and file identifiers
            guard sessionID == serverState.session?.sessionId else {
                sendResponse(connection: connection, serverResponse: createErrorResponse(.unauthorized))
                return nil
            }
            guard let fileInfo = serverState.session?.files[fileID],
                  fileInfo.transmissionId == transmissionID,
                  let fileName = fileInfo.file.fileName else {
                sendResponse(connection: connection, serverResponse: createErrorResponse(.forbidden))
                return nil
            }
            
            if request.bodyFullyReceived {
                // File upload complete
                sendSuccessResponse(connection: connection, endpoint: .upload)
                fileInfo.status = .finished
                serverState.session?.files[fileID] = fileInfo
                checkAllFilesReceived()
                return nil
            } else {
                // File upload starting: provide a temp file URL to write incoming data
                let fileURL = FileManager.tempDirectory(withFileName: fileName)
                fileInfo.status = .transferring
                fileInfo.url = fileURL
                serverState.session?.files[fileID] = fileInfo
                return fileURL
            }
        } catch {
            debugLog("Error processing file upload request")
            sendResponse(connection: connection, serverResponse: createErrorResponse(.badRequest))
            return nil
        }
    }
    
    /// Update progress for a file upload.
    func processProgress(connection: NWConnection, bytesReceived: Int, for request: HTTPRequest) {
        do {
            let uploadReq: FileUploadRequest = try request.queryParameters.decode(FileUploadRequest.self)
            guard let fileID = uploadReq.fileID,
                  let fileInfo = serverState.session?.files[fileID] else {
                // Can't find matching file info
                sendResponse(connection: connection, serverResponse: createErrorResponse(.badRequest))
                return
            }
            // Update the bytes received for the file and notify progress
            fileInfo.bytesReceived += bytesReceived
            serverState.session?.files[fileID] = fileInfo
            eventPublisher.send(.fileTransferProgress(fileInfo))
        } catch {
            debugLog("Failed to decode file upload progress")
            // We could send an error event here if needed
        }
    }
    
    func handleUploadFailure(connection: NWConnection, request: HTTPRequest?) {
        guard let req = request else {
            return
        }
        
        if let uploadReq: FileUploadRequest = try? req.queryParameters.decode(FileUploadRequest.self),
           let fileID = uploadReq.fileID {
            serverState.session?.files[fileID]?.status = .failed
        }
        
        checkAllFilesReceived()
    }
    
    /// Check if all files in the current session have been received or completed.
    private func checkAllFilesReceived() {
        guard let files = serverState.session?.files else { return }
        let pendingFiles = files.values.filter { $0.status == .transferring || $0.status == .queue }
        if pendingFiles.isEmpty {
            // All files are finished transferring
            eventPublisher.send(.allTransfersCompleted)
        }
    }
}

// MARK: - CloseConnectionHandler Implementation

extension NearbySharingServer: CloseConnectionHandler {
    func handleCloseConnectionRequest(on connection: NWConnection, request: HTTPRequest) {
        do {
            let closeResponse = try generateCloseConnectionResponse(from: request.body)
            sendResponse(connection: connection, serverResponse: closeResponse)
        } catch let statusError as HTTPStatusCode {
            sendResponse(connection: connection, serverResponse: createErrorResponse(statusError))
        } catch {
            sendInternalServerError(connection: connection)
        }
    }
    
    func generateCloseConnectionResponse(from requestBody: String) throws -> NearbySharingServerResponse {
        guard let closeReq = requestBody.decodeJSON(CloseConnectionRequest.self) else {
            throw HTTPStatusCode.badRequest
        }
        
        guard closeReq.sessionID == serverState.session?.sessionId else {
            throw HTTPStatusCode.unauthorized
        }
        
        let payload = BoolResponse(success: true)
        guard let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(payload)
            .closeConnection()
            .build() else {
            throw HTTPStatusCode.internalServerError
        }
        
        return NearbySharingServerResponse(dataResponse: responseData, response: .success, endpoint: .closeConnection)
    }
}

// MARK: - Stub Extension

extension NearbySharingServer {
    static func stub() -> NearbySharingServer {
        return NearbySharingServer()
    }
}
