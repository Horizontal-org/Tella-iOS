//
//  PeerToPeerServer.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Network
import Combine
import Foundation

final class PeerToPeerServer: NetworkManagerDelegate {
    
    // MARK: - Properties
    
    private let networkManager = NetworkManager()
    private(set) var serverState = P2PServerState()
    
    /// Single Combine publisher for all server events.
    var eventPublisher = PassthroughSubject<PeerToPeerEvent, Never>()
    
    /// Stored context for pending user decisions.
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

    func resetServer() {
        networkManager.stopListening()
        resetConnectionState()
    }
    
    func cleanServer() {
        cleanTempFiles()
        resetServer()
    }
    
    private func cleanTempFiles() {
        // Remove any temporary files that were stored during transfers
        guard let fileURLs = serverState.session?.files.values.compactMap({ $0.url }) else { return }
        fileURLs.forEach { $0.remove() }
    }
    
    private func resetConnectionState() {
        // Reset session state and pending request info
        serverState.reset()
        pendingRegisterConnection = nil
        pendingRegisterRequest = nil
        pendingUploadConnection = nil
        eventPublisher = PassthroughSubject<PeerToPeerEvent, Never>()
    }
    
    // MARK: - Responding to User Decisions
    
    /// Call this to respond to a pending registration request (from a `.registrationRequested` event).
    func respondToRegistrationRequest(accept: Bool) {
        guard let connection = pendingRegisterConnection,
              let request = pendingRegisterRequest else {
            return  // No pending request to respond to
        }
        if accept {
            acceptRegisterRequest(connection: connection, httpRequest: request)
        } else {
            discardRegisterRequest(connection: connection)
        }
        // Clear the pending request after responding
        pendingRegisterConnection = nil
        pendingRegisterRequest = nil
    }
    
    /// Call this to respond to a pending file upload offer (from a `.prepareUploadReceived` event).
    func respondToFileOffer(accept: Bool) {
        guard let connection = pendingUploadConnection else {
            return  // No pending file offer to respond to
        }
        sendPrepareUploadResponse(connection: connection, accept: accept)
        pendingUploadConnection = nil
    }
    
    // MARK: - Internal Request Handling
    
    private func acceptRegisterRequest(connection: NWConnection, httpRequest: HTTPRequest) {
        do {
            let serverResponse = try generateRegisterServerResponse(from: httpRequest)
            sendResponse(connection: connection, serverResponse: serverResponse)
        } catch let statusError as HTTPStatusCode {
            // Known HTTP error (e.g., conflict, unauthorized, etc.)
            sendResponse(connection: connection, serverResponse: createErrorResponse(statusError))
        } catch {
            // Unexpected error
            sendInternalServerError(connection: connection)
        }
    }
    
    private func discardRegisterRequest(connection: NWConnection) {
        // Deny the registration request with 401 Unauthorized
        sendResponse(connection: connection, serverResponse: createErrorResponse(.unauthorized))
    }
    
    private func sendPrepareUploadResponse(connection: NWConnection, accept: Bool) {
        let response = accept ? createAcceptUploadResponse() : createRejectUploadResponse()
        sendResponse(connection: connection, serverResponse: response)
    }
    
    // MARK: - Core Request Processing
    
    /// Process a completed HTTP request (headers and full body if applicable).
    private func processRequest(connection: NWConnection, httpRequest: HTTPRequest, bodyFileHandler: ((URL) -> Void)? = nil) {
        guard let endpoint = PeerToPeerEndpoint(rawValue: httpRequest.endpoint) else {
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
            handleFileUploadRequest(on: connection, request: httpRequest, bodyFileHandler: bodyFileHandler)
        case .closeConnection:
            handleCloseConnectionRequest(on: connection, request: httpRequest)
        }
    }
    
    /// Update progress for a file upload.
    private func processProgress(connection: NWConnection, bytesReceived: Int, for request: HTTPRequest) {
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
    
    // MARK: - Endpoint-specific Handlers
    
    private func handlePingRequest(on connection: NWConnection) {
        // A ping indicates a new manual connection attempt.
        eventPublisher.send(.verificationRequested)
        serverState.isUsingManualConnection = true
        // Respond to the ping with success (to acknowledge).
        sendSuccessResponse(connection: connection, endpoint: .ping)
    }
    
    private func handleRegisterRequest(on connection: NWConnection, request: HTTPRequest) {
        if serverState.isUsingManualConnection {
            // Manual mode: store the request and ask the user for confirmation.
            pendingRegisterConnection = connection
            pendingRegisterRequest = request
            eventPublisher.send(.registrationRequested)
            // (The actual response will be sent when `respondToRegistrationRequest` is called.)
        } else {
            // Automatic mode: process registration immediately.
            acceptRegisterRequest(connection: connection, httpRequest: request)
        }
    }
    
    private func generateRegisterServerResponse(from request: HTTPRequest) throws -> P2PServerResponse {
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
        serverState.session = P2PSession(sessionId: UUID().uuidString)
        // Build a success response with the new session ID
        let payload = RegisterResponse(sessionId: serverState.session!.sessionId)
        guard let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(payload)
            .closeConnection()
            .build() else {
            throw HTTPStatusCode.internalServerError
        }
        return P2PServerResponse(dataResponse: responseData, response: .success, endpoint: .register)
    }
    
    private func handlePrepareUploadRequest(on connection: NWConnection, request: HTTPRequest) {
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
                serverState.session?.files[fileId] = P2PTransferredFile(file: file)
            }
        }
        // Save the connection and notify the UI about incoming files
        pendingUploadConnection = connection
        eventPublisher.send(.prepareUploadReceived(files: prepReq.files))
        // (UI will call `respondToFileOffer(accept:)` to continue.)
    }
    
    private func handleFileUploadRequest(on connection: NWConnection, request: HTTPRequest, bodyFileHandler: ((URL) -> Void)?) {
        do {
            let uploadReq: FileUploadRequest = try request.queryParameters.decode(FileUploadRequest.self)
            guard let fileID = uploadReq.fileID,
                  let transmissionID = uploadReq.transmissionID,
                  let sessionID = uploadReq.sessionID else {
                sendResponse(connection: connection, serverResponse: createErrorResponse(.badRequest))
                return
            }
            // Validate session and file identifiers
            guard sessionID == serverState.session?.sessionId else {
                sendResponse(connection: connection, serverResponse: createErrorResponse(.unauthorized))
                return
            }
            guard let fileInfo = serverState.session?.files[fileID],
                  fileInfo.transmissionId == transmissionID,
                  let fileName = fileInfo.file.fileName else {
                sendResponse(connection: connection, serverResponse: createErrorResponse(.forbidden))
                return
            }
            
            if request.bodyFullyReceived {
                // File upload complete
                sendSuccessResponse(connection: connection, endpoint: .upload)
                fileInfo.status = .finished
                serverState.session?.files[fileID] = fileInfo
                checkAllFilesReceived()
            } else {
                // File upload starting: provide a temp file URL to write incoming data
                let fileURL = FileManager.tempDirectory(withFileName: fileName)
                fileInfo.status = .transferring
                fileInfo.url = fileURL
                serverState.session?.files[fileID] = fileInfo
                bodyFileHandler?(fileURL)
            }
        } catch {
            debugLog("Error processing file upload request")
            sendResponse(connection: connection, serverResponse: createErrorResponse(.badRequest))
        }
    }
    
    private func handleCloseConnectionRequest(on connection: NWConnection, request: HTTPRequest) {
        do {
            let closeResponse = try generateCloseConnectionResponse(from: request.body)
            sendResponse(connection: connection, serverResponse: closeResponse)
        } catch let statusError as HTTPStatusCode {
            sendResponse(connection: connection, serverResponse: createErrorResponse(statusError))
        } catch {
            sendInternalServerError(connection: connection)
        }
    }
    
    private func generateCloseConnectionResponse(from requestBody: String) throws -> P2PServerResponse {
        guard let closeReq = requestBody.decodeJSON(CloseConnectionRequest.self) else {
            throw HTTPStatusCode.badRequest
        }
        guard closeReq.sessionID == serverState.session?.sessionId else {
            throw HTTPStatusCode.unauthorized
        }
        // Build a success response indicating the connection will close
        let payload = BoolResponse(success: true)
        guard let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(payload)
            .closeConnection()
            .build() else {
            throw HTTPStatusCode.internalServerError
        }
        return P2PServerResponse(dataResponse: responseData, response: .success, endpoint: .closeConnection)
    }
    
    // MARK: - Response Helpers
    
    private func createAcceptUploadResponse() -> P2PServerResponse {
        // Assign unique transmission IDs for each file and prepare the response payload
        var filesResponse: [P2PFileResponse] = []
        serverState.session?.files.forEach { (fileID, fileInfo) in
            let transmissionId = UUID().uuidString
            // Update the file info with the new transmission ID
            serverState.session?.files[fileID]?.transmissionId = transmissionId
            filesResponse.append(P2PFileResponse(id: fileInfo.file.id, transmissionID: transmissionId))
        }
        let payload = PrepareUploadResponse(files: filesResponse)
        guard let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(payload)
            .closeConnection()
            .build() else {
            return createErrorResponse(.internalServerError)
        }
        return P2PServerResponse(dataResponse: responseData, response: .success, endpoint: .prepareUpload)
    }
    
    private func createRejectUploadResponse() -> P2PServerResponse {
        // Deny the upload request with Forbidden status
        return createErrorResponse(.forbidden)
    }
    
    private func createErrorResponse(_ status: HTTPStatusCode) -> P2PServerResponse {
        // Build an HTTP error response with the given status
        let errorPayload = ErrorMessage(error: status.reasonPhrase)
        let responseData = HTTPResponseBuilder(status: status)
            .setContentType(.json)
            .setBody(errorPayload)
            .closeConnection()
            .build()
        return P2PServerResponse(dataResponse: responseData, response: .failure, endpoint: nil)
    }
    
    private func sendSuccessResponse(connection: NWConnection, endpoint: PeerToPeerEndpoint) {
        // Send a simple success=true JSON response for endpoints like ping or upload
        let payload = BoolResponse(success: true)
        guard let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(payload)
            .closeConnection()
            .build() else {
            sendInternalServerError(connection: connection)
            return
        }
        let response = P2PServerResponse(dataResponse: responseData, response: .success, endpoint: endpoint)
        sendData(connection: connection, serverResponse: response)
    }
    
    // MARK: - Low-level Response Sending
    
    private func sendResponse(connection: NWConnection, serverResponse: P2PServerResponse?) {
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
    
    private func sendData(connection: NWConnection, serverResponse: P2PServerResponse) {
        guard let data = serverResponse.dataResponse else {
            debugLog("No data to send for response.")
            return
        }
        networkManager.sendData(connection: connection, data) { [weak self] error in
            if error != nil {
                debugLog("Failed to send response data")
                // We could emit an event for send failure if needed
                return
            }
            // On successful send, handle post-send actions
            self?.handleResponseSent(serverResponse)
        }
    }
    
    private func handleResponseSent(_ serverResponse: P2PServerResponse) {
        guard let endpoint = serverResponse.endpoint else { return }
        let success = (serverResponse.response == .success)
        switch endpoint {
        case .register:
            // Notify listeners whether registration succeeded (manual or auto)
            eventPublisher.send(.didRegister(success: success, manual: serverState.isUsingManualConnection))
        case .prepareUpload:
            // Notify that we replied to the file upload offer
            eventPublisher.send(.prepareUploadResponseSent(success: success))
        case .closeConnection:
            // The connection is about to close
            eventPublisher.send(.connectionClosed)
            resetServer()  // Clean up server state after closing
        case .upload, .ping:
            // No special action needed after sending these responses
            break
        }
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
    
    private func handleError(for request: HTTPRequest?, on connection: NWConnection) {
        // Generic error handler for failed requests or connections
        guard let req = request,
              let endpoint = PeerToPeerEndpoint(rawValue: req.endpoint) else {
            sendInternalServerError(connection: connection)
            return
        }
        if endpoint == .upload {
            // Mark the file as failed if we know which file was uploading
            if let uploadReq: FileUploadRequest = try? req.queryParameters.decode(FileUploadRequest.self),
               let fileID = uploadReq.fileID {
                serverState.session?.files[fileID]?.status = .failed
            }
            sendInternalServerError(connection: connection)
            checkAllFilesReceived()  // finalize if this was the last file
        } else {
            sendInternalServerError(connection: connection)
        }
    }
    
    // MARK: - NetworkManagerDelegate
    
    func networkManager(didFailWithListener error: Error?) {
        debugLog("Server failed to start")
        eventPublisher.send(.serverStartFailed(error))
    }
    
    func networkManager(_ connection: NWConnection, didFailWith error: Error?, request: HTTPRequest?) {
        // Handle connection/request failure
        handleError(for: request, on: connection)
    }
    
    func networkManager(_ connection: NWConnection, didReceiveCompleteRequest request: HTTPRequest) {
        // Received a full request (possibly with body fully read)
        processRequest(connection: connection, httpRequest: request)
    }
    
    func networkManager(_ connection: NWConnection, verifyParametersForDataRequest request: HTTPRequest, completion: ((URL) -> Void)?) {
        // Received request headers for a data upload; provide file URL for streaming data
        processRequest(connection: connection, httpRequest: request, bodyFileHandler: completion)
    }
    
    func networkManager(_ connection: NWConnection, didReceive bytes: Int, for request: HTTPRequest) {
        // Received a chunk of data for an ongoing upload
        processProgress(connection: connection, bytesReceived: bytes, for: request)
    }
    
    func networkManagerDidStartListening() {
        debugLog("Server is now listening on the specified port.")
        // Optionally, we could emit an event here to indicate the server started successfully.
    }
    
    func networkManagerDidStopListening() {
        debugLog("Server stopped listening.")
        // Notify that any ongoing transfers should be considered complete/terminated
        eventPublisher.send(.allTransfersCompleted)
    }
}

extension PeerToPeerServer {
    static func stub() -> PeerToPeerServer {
        return PeerToPeerServer()
    }
}

struct CurrentFileUploadInfo {
    var url: URL
    var fileID: String
}
