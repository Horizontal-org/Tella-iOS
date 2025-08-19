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

final class NearbySharingServer {
    
    let state = NearbySharingStateActor()
    private let networkManager = NetworkManager()
    
    /// Single Combine publisher for all server events.
    var eventPublisher = PassthroughSubject<NearbySharingEvent, Never>()
    
    init() {
        Task {
            await networkManager.setDelegate(self)
        }
    }
    
    // MARK: - Server Lifecycle
    
    func startListening(port: Int, pin: String, clientIdentity: SecIdentity) {
        Task {
            await state.setPin(pin)
            await networkManager.startListening(port: port, clientIdentity: clientIdentity)
        }
    }
    
    func stopServer() {
        Task {
            await networkManager.stopListening()
        }
    }
    
    func resetServerState() {
        stopServer()
        Task { await state.resetConnectionState() }
        eventPublisher = PassthroughSubject<NearbySharingEvent, Never>()
    }
    
    func resetFullServerState() {
        stopServer()
        cleanServer()
    }
    
    func cleanServer() {
        Task {
            await networkManager.cleanConnections()
            await state.removeTempFiles()
            await state.resetConnectionState()
        }
        eventPublisher = PassthroughSubject<NearbySharingEvent, Never>()
    }
    
    // MARK: - Response Helpers
    
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
    
    private func createErrorResponse(_ status: HTTPStatusCode, endpoint: NearbySharingEndpoint? = nil) -> NearbySharingServerResponse {
        let errorPayload = ErrorMessage(error: status.reasonPhrase)
        let responseData = HTTPResponseBuilder(status: status)
            .setContentType(.json)
            .setBody(errorPayload)
            .closeConnection()
            .build()
        return NearbySharingServerResponse(dataResponse: responseData, response: .failure, endpoint: endpoint)
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
            Task {
                let manual = await state.isManualConnection()
                eventPublisher.send(.didRegister(success: success, manual: manual))
            }
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
            handleReceivedCompleteRequest(on: connection, request: httpRequest)
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
        guard let context else { return }
        handleError(for: context.request, on: context.connection)
    }
    
    func networkManager(didReceiveCompleteRequest context: ConnectionContext) {
        processRequest(connection: context.connection, httpRequest: context.request)
    }
    
    func networkManager(verifyParametersFor context: ConnectionContext) async -> URL? {
        guard context.request.endpoint == NearbySharingEndpoint.upload.rawValue else {
            return nil
        }
        return await handleFileUploadRequest(on: context.connection, request: context.request)
    }
    
    func networkManager(didReceive bytes: Int, for context: ConnectionContext) {
        processProgress(connection: context.connection, bytesReceived: bytes, for: context.request)
    }
}

// MARK: - PingHandler

extension NearbySharingServer: PingHandler {
    func handlePingRequest(on connection: NWConnection) {
        eventPublisher.send(.verificationRequested)
        Task { await state.markManualConnection() }
        sendSuccessResponse(connection: connection, endpoint: .ping)
    }
}

// MARK: - RegisterHandler

extension NearbySharingServer: RegisterHandler {
    func handleRegisterRequest(on connection: NWConnection, request: HTTPRequest) {
        Task {
            if await state.isManualConnection() {
                await state.setPendingRegister(connection: connection, request: request)
                eventPublisher.send(.registrationRequested)
            } else {
                await acceptRegisterRequest(connection: connection, httpRequest: request)
            }
        }
    }
    
    func generateRegisterServerResponse(from request: HTTPRequest) async throws -> NearbySharingServerResponse {
        // 1) existing session / rate limiting
        if await state.hasSession() {
            throw HTTPStatusCode.conflict
        }
        if await state.tooManyAttempts() {
            throw HTTPStatusCode.tooManyRequests
        }
        
        // 2) decode body
        guard let regReq = request.body.decodeJSON(RegisterRequest.self) else {
            throw HTTPStatusCode.badRequest
        }
        
        // 3) verify PIN
        guard let pin = regReq.pin, await state.pinMatches(pin) else {
            await state.incrementFailedAttempts()
            if await state.tooManyAttempts() {
                throw HTTPStatusCode.tooManyRequests
            }
            throw HTTPStatusCode.unauthorized
        }
        
        // 4) create session
        let newSessionId = await state.createSessionAndReturnID()
        
        // 5) response
        let payload = RegisterResponse(sessionId: newSessionId)
        guard let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(payload)
            .closeConnection()
            .build() else {
            throw HTTPStatusCode.internalServerError
        }
        
        return NearbySharingServerResponse(dataResponse: responseData, response: .success, endpoint: .register)
    }
    
    func respondToRegistrationRequest(accept: Bool) {
        Task {
            guard let (connection, request) = await state.getPendingRegister() else { return }
            if accept {
                await acceptRegisterRequest(connection: connection, httpRequest: request)
            } else {
                discardRegisterRequest(connection: connection)
            }
        }
    }
    
    private func acceptRegisterRequest(connection: NWConnection, httpRequest: HTTPRequest) async {
        do {
            let serverResponse = try await generateRegisterServerResponse(from: httpRequest)
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

// MARK: - PrepareUploadHandler

extension NearbySharingServer: PrepareUploadHandler {
    
    func handlePrepareUploadRequest(on connection: NWConnection, request: HTTPRequest) {
        guard let prepReq = request.body.decodeJSON(PrepareUploadRequest.self) else {
            sendResponse(connection: connection, serverResponse: createErrorResponse(.badRequest))
            return
        }
        
        Task {
            let sessionID = await state.currentSessionID()
            guard prepReq.sessionID == sessionID else {
                sendResponse(connection: connection, serverResponse: createErrorResponse(.unauthorized))
                return
            }
            
            await state.storePrepareUpload(prepReq)
            await state.setPendingUploadConnection(connection)
            eventPublisher.send(.prepareUploadReceived(files: prepReq.files))
        }
    }
    
    private func createAcceptUploadResponse() async -> NearbySharingServerResponse {
        let fileTuples = await state.assignTransmissionIDs()
        let filesResponse = fileTuples.map {
            NearbySharingFileResponse(id: $0.originalID, transmissionID: $0.transmissionID)
        }
        
        let payload = PrepareUploadResponse(files: filesResponse)
        guard let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(payload)
            .closeConnection()
            .build() else {
            return createErrorResponse(.internalServerError)
        }
        
        return NearbySharingServerResponse(
            dataResponse: responseData,
            response: .success,
            endpoint: .prepareUpload
        )
    }
    
    private func sendPrepareUploadResponse(connection: NWConnection, accept: Bool) async {
        let response = accept ? await createAcceptUploadResponse()
        : createRejectUploadResponse()
        sendResponse(connection: connection, serverResponse: response)
    }
    
    func respondToFileOffer(accept: Bool) {
        Task {
            guard let connection = await state.getPendingUploadConnection() else { return }
            await sendPrepareUploadResponse(connection: connection, accept: accept)
        }
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
            
            // --- Validate query params ---
            guard let fileID = uploadReq.fileID,
                  let transmissionID = uploadReq.transmissionID,
                  let sessionID = uploadReq.sessionID else {
                sendResponse(connection: connection, serverResponse: createErrorResponse(.badRequest))
                return nil
            }
            
            // --- Validate session ---
            let currentID = await state.currentSessionID()
            guard sessionID == currentID else {
                sendResponse(connection: connection, serverResponse: createErrorResponse(.unauthorized))
                return nil
            }
            
            // --- Validate file + transmission, grab fileName for mutations ---
            guard let fileInfo = await state.fileInfo(for: fileID),
                  fileInfo.transmissionId == transmissionID,
                  let fileType = fileInfo.file.fileType else {
                sendResponse(connection: connection, serverResponse: createErrorResponse(.forbidden))
                return nil
            }
            
            let url = await state.beginUpload(fileID: fileID, fileType: fileType)
            return url
            
        } catch {
            debugLog("Error processing file upload request: \(error)")
            sendResponse(connection: connection, serverResponse: createErrorResponse(.badRequest))
            return nil
        }
    }
    
    func handleReceivedCompleteRequest(on connection: NWConnection, request: HTTPRequest) {
        
        Task { do {
            
            let uploadReq: FileUploadRequest = try request.queryParameters.decode(FileUploadRequest.self)
            
            guard let fileID = uploadReq.fileID else {
                sendResponse(connection: connection, serverResponse: createErrorResponse(.badRequest))
                return
            }
            
            await state.markUploadFinished(fileID: fileID)
            
            if let fileInfo = await state.fileInfo(for: fileID) {
                eventPublisher.send(.fileTransferProgress(fileInfo))
            }
            
            if await state.allTransfersCompleted() {
                eventPublisher.send(.allTransfersCompleted)
            }
            
            sendSuccessResponse(connection: connection, endpoint: .upload)
            
        } catch {
            debugLog("Error processing file upload request: \(error)")
            sendResponse(connection: connection, serverResponse: createErrorResponse(.badRequest))
            return
        }
        }
    }
    
    func processProgress(connection: NWConnection, bytesReceived: Int, for request: HTTPRequest) {
        guard let uploadReq: FileUploadRequest = try? request.queryParameters.decode(FileUploadRequest.self),
              let fileID = uploadReq.fileID else {
            sendResponse(connection: connection, serverResponse: createErrorResponse(.badRequest))
            return
        }
        
        Task {
            if let updated = await state.updateUploadProgress(fileID: fileID, bytes: bytesReceived) {
                eventPublisher.send(.fileTransferProgress(updated))
            }
        }
    }
    
    func handleUploadFailure(connection: NWConnection, request: HTTPRequest?) {
        guard
            let req = request,
            let uploadReq: FileUploadRequest = try? req.queryParameters.decode(FileUploadRequest.self),
            let fileID = uploadReq.fileID
        else { return }
        
        Task {
            await state.markUploadFailed(fileID: fileID)
            if await state.allTransfersCompleted() {
                eventPublisher.send(.allTransfersCompleted)
            }
        }
    }
}

// MARK: - CloseConnectionHandler

extension NearbySharingServer: CloseConnectionHandler {
    
    func handleCloseConnectionRequest(on connection: NWConnection, request: HTTPRequest) {
        Task {
            do {
                let closeResponse = try await generateCloseConnectionResponse(from: request.body)
                sendResponse(connection: connection, serverResponse: closeResponse)
            } catch let statusError as HTTPStatusCode {
                sendResponse(connection: connection, serverResponse: createErrorResponse(statusError))
            } catch {
                sendInternalServerError(connection: connection)
            }
        }
    }
    
    func generateCloseConnectionResponse(from requestBody: String) async throws -> NearbySharingServerResponse {
        guard let closeReq = requestBody.decodeJSON(CloseConnectionRequest.self) else {
            throw HTTPStatusCode.badRequest
        }
        
        let sessionID = await state.currentSessionID()
        guard closeReq.sessionID == sessionID else {
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
        
        return NearbySharingServerResponse(
            dataResponse: responseData,
            response: .success,
            endpoint: .closeConnection
        )
    }
}

// MARK: - Stub

extension NearbySharingServer {
    static func stub() -> NearbySharingServer { NearbySharingServer() }
}
