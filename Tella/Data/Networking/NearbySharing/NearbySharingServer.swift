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
    private let rateLimiter = NearbySharingRateLimiter()
    
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
            await rateLimiter.reset()
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
    
    private func sendSuccessResponse(connection: NWConnection, payload: Encodable, endpoint: NearbySharingEndpoint) {
        guard let responseData = HTTPResponseBuilder(serverStatus: ServerStatus(code: .ok, message: .ok))
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
    
    private func sendErrorResponse(_ error: ServerStatus, connection: NWConnection, endpoint: NearbySharingEndpoint? = nil) {
        let errorPayload = ErrorResponse(error: error.message.rawValue)
        let responseData = HTTPResponseBuilder(serverStatus: error)
            .setContentType(.json)
            .setBody(errorPayload)
            .closeConnection()
            .build()
        let response = NearbySharingServerResponse(dataResponse: responseData, response: .failure, endpoint: endpoint)
        sendData(connection: connection, serverResponse: response)
    }
    
    private func sendInternalServerError(connection: NWConnection) {
        let error = ServerStatus(code: .internalServerError, message: .serverError)
        sendErrorResponse(error,connection: connection)
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
    
    private func handleError(error: Error? = nil, for request: HTTPRequest?, on connection: NWConnection) {
        guard let req = request,
              let endpoint = NearbySharingEndpoint(rawValue: req.endpoint) else {
            return
        }
        
        if endpoint == .upload {
            if let error, error.isInsufficientStorageError {
                sendErrorResponse(
                    ServerStatus(code: .insufficientStorage, message: .insufficientStorage),
                    connection: connection,
                    endpoint: .upload
                )
            }
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
        handleError(error: error, for: context.request, on: context.connection)
    }
    
    func networkManager(didReceiveCompleteRequest context: ConnectionContext) {
        Task {
            let ip = NearbySharingClientIP.string(from: context.connection)
            let route = context.request.endpoint
            
            let limited = await rateLimiter.isLimited(ip: ip, route: route)
            if limited {
                let endpoint = NearbySharingEndpoint(rawValue: route)
                sendErrorResponse(
                    ServerStatus(code: .tooManyRequests, message: .tooManyRequests),
                    connection: context.connection,
                    endpoint: endpoint
                )
                return
            }
            processRequest(connection: context.connection, httpRequest: context.request)
        }
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
        let payload = BoolResponse(success: true)
        sendSuccessResponse(connection: connection,payload: payload, endpoint: .ping)
    }
}

// MARK: - RegisterHandler

extension NearbySharingServer: RegisterHandler {
    func handleRegisterRequest(on connection: NWConnection, request: HTTPRequest) {
        Task {
            if await state.isManualConnection() {
                
                if let pendingRegisterResponse = await state.getPendingRegisterResponse() {
                    await sendRegistrationResponse(accept: pendingRegisterResponse,
                                                   connection: connection,
                                                   request: request)
                } else {
                    await state.setPendingRegister(connection: connection, request: request)
                }
                
            } else {
                await acceptRegisterRequest(connection: connection, httpRequest: request)
            }
        }
    }
    
    func acceptRegisterRequest(connection: NWConnection, httpRequest: HTTPRequest) async {
        
        if await state.hasSession() {
            let error = ServerStatus(code: .conflict, message: .activeSessionAlreadyExists)
            sendErrorResponse(error, connection: connection)
            return
        }
        
        guard let regReq = httpRequest.body.decodeJSON(RegisterRequest.self) else {
            let error = ServerStatus(code: .badRequest, message: .invalidRequestFormat)
            sendErrorResponse(error, connection: connection)
            return
        }
        
        guard let nonce = regReq.nonce, !nonce.isEmpty else {
            let error = ServerStatus(code: .badRequest, message: .invalidRequestFormat)
            sendErrorResponse(error, connection: connection)
            return
        }
        
        if await state.hasReachedMaxAttempts(for: nonce) {
            let error = ServerStatus(code: .tooManyRequests, message: .tooManyRequests)
            sendErrorResponse(error, connection: connection)
            return
        }
        
        guard let pin = regReq.pin, await state.pinMatches(pin) else {
            await state.recordRegisterPinFailure(for: nonce)
            if await state.hasReachedMaxAttempts(for: nonce) {
                let error = ServerStatus(code: .tooManyRequests, message: .tooManyRequests)
                sendErrorResponse(error, connection: connection)
                return
            }
            let error = ServerStatus(code: .unauthorized, message: .invalidPIN)
            sendErrorResponse(error, connection: connection)
            return
        }
        
        let newSessionId = await state.createSessionAndReturnID(registrationNonce: nonce)
        
        // 5) response
        let payload = RegisterResponse(sessionId: newSessionId)
        sendSuccessResponse(connection: connection,
                            payload: payload,
                            endpoint: .register)
    }
    
    func respondToRegistrationRequest(accept: Bool) {
        Task {
            guard let (connection, request) = await state.getPendingRegister() else {
                await state.savePendingRegisterResponse(accept: accept)
                return
            }
            await sendRegistrationResponse(accept: accept,
                                           connection: connection,
                                           request: request)
        }
    }
    
    private func sendRegistrationResponse(accept: Bool,
                                          connection: NWConnection,
                                          request: HTTPRequest) async {
        if accept {
            await acceptRegisterRequest(connection: connection, httpRequest: request)
        } else {
            discardRegisterRequest(connection: connection)
        }
    }
    
    private func discardRegisterRequest(connection: NWConnection) {
        let error = ServerStatus(code: .forbidden, message: .rejected)
        sendErrorResponse(error, connection: connection)
    }
}

// MARK: - PrepareUploadHandler

extension NearbySharingServer: PrepareUploadHandler {
    
    func handlePrepareUploadRequest(on connection: NWConnection, request: HTTPRequest) {
        guard let prepReq = request.body.decodeJSON(PrepareUploadRequest.self) else {
            let error = ServerStatus(code: .badRequest, message: .invalidRequestFormat)
            sendErrorResponse(error, connection: connection)
            return
        }
        
        Task {
            let sessionID = await state.currentSessionID()
            guard prepReq.sessionID == sessionID else {
                let error = ServerStatus(code: .unauthorized, message: .invalidSessionID)
                sendErrorResponse(error, connection: connection)
                return
            }
            
            if let nonceError = await state.addTransferNonce(prepReq.nonce) {
                sendErrorResponse(nonceError.serverStatus, connection: connection, endpoint: .prepareUpload)
                return
            }
            
            await state.storePrepareUpload(prepReq)
            await state.setPendingUploadConnection(connection)
            eventPublisher.send(.prepareUploadReceived(files: prepReq.files))
        }
    }
    
    func respondToFileOffer(accept: Bool) {
        Task {
            guard let connection = await state.getPendingUploadConnection() else { return }
            await sendPrepareUploadResponse(connection: connection, accept: accept)
        }
    }
    
    private func sendPrepareUploadResponse(connection: NWConnection, accept: Bool) async {
        accept ? await sendAcceptUploadResponse(connection: connection)
        : sendRejectUploadResponse(connection:connection)
    }
    
    private func sendAcceptUploadResponse(connection: NWConnection) async {
        let fileTuples = await state.assignTransmissionIDs()
        let filesResponse = fileTuples.map {
            NearbySharingFileResponse(id: $0.originalID, transmissionID: $0.transmissionID)
        }
        
        let payload = PrepareUploadResponse(files: filesResponse)
        sendSuccessResponse(connection: connection,
                            payload: payload,
                            endpoint: .prepareUpload)
    }
    
    private func sendRejectUploadResponse(connection: NWConnection) {
        let error = ServerStatus(code: .forbidden, message: .rejected)
        sendErrorResponse(error, connection: connection,endpoint: .prepareUpload)
    }
}

// MARK: - UploadHandler Implementation

extension NearbySharingServer: UploadHandler {
    
    func handleFileUploadRequest(on connection: NWConnection, request: HTTPRequest) async -> URL? {
        do {
            return try await state.beginUploadFromRequest(request)
        } catch let status as ServerStatus {
            sendErrorResponse(status, connection: connection, endpoint: .upload)
            return nil
        } catch {
            debugLog("Error processing file upload request: \(error)")
            sendErrorResponse(
                ServerStatus(code: .badRequest, message: .invalidRequestFormat),
                connection: connection,
                endpoint: .upload
            )
            return nil
        }
    }
    
    
    
    func handleReceivedCompleteRequest(on connection: NWConnection, request: HTTPRequest) {
        Task {
            switch await state.finalizeUpload(from: request) {
            case .success(let file):
                eventPublisher.send(.fileTransferProgress(file))
                let payload = BoolResponse(success: true)
                sendSuccessResponse(connection: connection, payload: payload, endpoint: .upload)
            case .failure(let status, let file):
                if let file {
                    eventPublisher.send(.fileTransferProgress(file))
                }
                sendErrorResponse(status, connection: connection, endpoint: .upload)
            }
        }
    }
    
    func processProgress(connection: NWConnection, bytesReceived: Int, for request: HTTPRequest) {
        guard let uploadReq: FileUploadRequest = try? request.queryParameters.decode(FileUploadRequest.self),
              let fileID = uploadReq.fileID else {
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
            
            if let fileInfo = await state.fileInfo(for: fileID) {
                eventPublisher.send(.fileTransferProgress(fileInfo))
            }
        }
    }
}

// MARK: - CloseConnectionHandler

extension NearbySharingServer: CloseConnectionHandler {
    
    func handleCloseConnectionRequest(on connection: NWConnection, request: HTTPRequest) {
        Task {
            guard let closeReq = request.body.decodeJSON(CloseConnectionRequest.self) else {
                
                let error = ServerStatus(code: .badRequest, message: .invalidRequestFormat)
                sendErrorResponse(error,connection: connection)
                return
            }
            
            let sessionID = await state.currentSessionID()
            guard closeReq.sessionID == sessionID else {
                
                let error = ServerStatus(code: .unauthorized, message: .activeSessionAlreadyExists)
                sendErrorResponse(error,connection: connection)
                return
            }
            
            let payload = BoolResponse(success: true)
            sendSuccessResponse(connection: connection,
                                payload: payload,
                                endpoint: .closeConnection)
        }
    }
}

// MARK: - Stub

extension NearbySharingServer {
    static func stub() -> NearbySharingServer { NearbySharingServer() }
}


