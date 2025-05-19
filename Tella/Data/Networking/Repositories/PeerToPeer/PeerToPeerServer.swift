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

final class PeerToPeerServer {
    
    // MARK: - Properties
    private var listener: NWListener?
    private var currentConnection: NWConnection?
    private var currentHTTPRequest: HTTPRequest?
    private var hasTLSError = false
    private var failedAttempts = 0
    
    // Server state
    private var fileData = Data()
    private var contentLength: Int?
    private var pin: String?
    private var sessionId: String?
    private var transmissionId: String?
    
    // Publishers
    let didRegisterPublisher = PassthroughSubject<Bool, Never>()
    let didRequestRegisterPublisher = PassthroughSubject<Void, Never>()
    let didCancelAuthenticationPublisher = PassthroughSubject<Void, Never>()
    let didReceivePrepareUploadPublisher = PassthroughSubject<[P2PFile], Never>()
    let didSendPrepareUploadResponsePublisher = PassthroughSubject<Bool, Never>()
    
    // MARK: - Server Lifecycle
    
    func startListening(port: Int, pin: String, clientIdentity: SecIdentity) {
        
        resetConnectionState()
        
        self.pin = pin
        
        do {
            let parameters = try createNetworkParameters(clientIdentity: clientIdentity)
            self.listener = try NWListener(using: parameters, on: NWEndpoint.Port(integerLiteral: UInt16(port)))
            
            setupListenerHandlers()
            self.listener?.start(queue: .main)
        } catch {
            debugLog("Failed to start listener: \(error.localizedDescription)")
        }
    }
    
    func stopListening() {
        listener?.cancel()
        currentConnection?.cancel()
        resetConnectionState()
    }
    
    // MARK: - Request Handling
    
    func acceptRegisterRequest() {
        do {
            let serverResponse = try generateRegisterServerResponse()
            handleServerResponse(serverResponse)
        } catch let error as HTTPError {
            handleServerResponse(createErrorResponse(error))
        } catch {
            sendInternalServerError()
        }
    }
    
    func discardRegisterRequest() {
        handleServerResponse(createErrorResponse(.unauthorized))
    }
    
    func sendPrepareUploadFiles(filesAccepted: Bool) {
        let serverResponse = filesAccepted ? createAcceptUploadResponse() : createRejectUploadResponse()
        handleServerResponse(serverResponse)
    }
    
    // MARK: - Private Methods
    
    private func createNetworkParameters(clientIdentity: SecIdentity) throws -> NWParameters {
        let tlsOptions = NWProtocolTLS.Options()
        let parameters = NWParameters(tls: tlsOptions)
        
        sec_protocol_options_set_local_identity(tlsOptions.securityProtocolOptions, sec_identity_create(clientIdentity)!)
        
        sec_protocol_options_set_challenge_block(tlsOptions.securityProtocolOptions, { (_, completionHandler) in
            completionHandler(sec_identity_create(clientIdentity)!)
        }, .main)
        
        return parameters
    }
    
    private func setupListenerHandlers() {
        listener?.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .ready:
                debugLog("Listener is ready and waiting for connections")
            case .failed(let error):
                debugLog("Listener failed: \(error.localizedDescription)")
                self.stopListening()
            case .cancelled:
                debugLog("Listener cancelled")
            default:
                break
            }
        }
        
        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleNewConnection(connection)
        }
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        currentConnection = connection
        connection.start(queue: .main)
        startReceive(on: connection)
    }
    
    private func startReceive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, _, error in
            if let error = error {
                self?.handleReceiveError(error)
                return
            }
            
            guard let data = data, let rawString = data.utf8String() else {
                debugLog("Failed to read HTTP data")
                return
            }
            
            debugLog("Received HTTP Request:\n\(rawString)")
            
            guard let httpRequest = rawString.parseHTTPRequest() else {
                debugLog("Failed to parse the HTTPRequest")
                return
            }
            
            self?.currentHTTPRequest = httpRequest
            self?.processHTTPRequest(httpRequest, on: connection)
        }
    }
    
    private func handleReceiveError(_ error: NWError) {
        debugLog("Connection error: \(error.localizedDescription)")
        
        if case .tls(let tlsErrorCode) = error {
            debugLog("TLS Error: \(tlsErrorCode)")
            didCancelAuthenticationPublisher.send()
            hasTLSError = true
        }
    }
    
    private func processHTTPRequest(_ httpRequest: HTTPRequest, on connection: NWConnection) {
        guard let expectedLength = httpRequest.headers.contentLength else {
            debugLog("Content-Length header missing")
            return
        }
        
        let body = httpRequest.body
        if body.utf8.count < expectedLength {
            debugLog("Body incomplete, waiting for more (\(body.utf8.count)/\(expectedLength))")
            receiveRemainingBody(on: connection, httpRequest: httpRequest,
                                 expectedLength: expectedLength, remaining: expectedLength - body.utf8.count)
        } else {
            debugLog("Full JSON Body: \(body)")
            processCompleteBody(body, httpRequest: httpRequest)
        }
    }
    
    private func receiveRemainingBody(on connection: NWConnection, httpRequest: HTTPRequest,
                                      expectedLength: Int, remaining: Int) {
        connection.receive(minimumIncompleteLength: remaining, maximumLength: remaining) { [weak self] data, _, _, error in
            if let error = error {
                debugLog("Error receiving remaining body: \(error)")
                return
            }
            
            guard let data = data, let more = data.utf8String() else {
                debugLog("Failed to decode remaining data")
                return
            }
            
            let fullBody = httpRequest.body + more
            debugLog("Full JSON Body after completion: \(fullBody)")
            self?.currentHTTPRequest?.body = fullBody
            
            self?.processCompleteBody(fullBody, httpRequest: httpRequest)
        }
    }
    
    private func processCompleteBody(_ body: String, httpRequest: HTTPRequest) {
        guard let endpoint = PeerToPeerEndpoint(rawValue: httpRequest.endpoint) else {
            debugLog("Unknown endpoint: \(httpRequest.endpoint)")
            return
        }
        
        switch endpoint {
        case .register:
            handleRegisterRequest()
        case .prepareUpload:
            handlePrepareUploadRequest(body: body)
        case .upload:
            handleFileUpload(body: body)
        case .closeConnection:
            stopListening()
        }
    }
    
    // MARK: - Request Processing
    
    private func handleRegisterRequest() {
        if hasTLSError {
            didRequestRegisterPublisher.send()
        } else {
            do {
                let serverResponse = try generateRegisterServerResponse()
                handleServerResponse(serverResponse)
            } catch let error as HTTPError {
                handleServerResponse(createErrorResponse(error))
            } catch {
                sendInternalServerError()
            }
        }
    }
    
    private func generateRegisterServerResponse() throws -> P2PServerResponse {
        guard let body = currentHTTPRequest?.body,
              let registerRequest = body.decodeJSON(RegisterRequest.self) else {
            throw HTTPError.badRequest
        }
        
        debugLog("Register request body: \(body)")
        
        if failedAttempts >= 3 {
            throw HTTPError.tooManyRequests
        }
        
        if sessionId != nil {
            throw HTTPError.conflict
        }
        
        guard pin == registerRequest.pin else {
            failedAttempts += 1
            throw HTTPError.unauthorized
        }
        
        let sessionId = UUID().uuidString
        self.sessionId = sessionId
        let response = RegisterResponse(sessionId: sessionId)
        
        guard let responseData = response.buildResponse() else {
            throw HTTPError.internalServerError
        }
        
        return P2PServerResponse(dataResponse: responseData, response: .success)
    }
    
    private func handlePrepareUploadRequest(body: String) {
        guard let prepareUploadRequest = body.decodeJSON(PrepareUploadRequest.self) else {
            handleServerResponse(createErrorResponse(.badRequest))
            return
        }
        
        guard prepareUploadRequest.sessionID == sessionId else {
            handleServerResponse(createErrorResponse(.unauthorized))
            return
        }
        
        didReceivePrepareUploadPublisher.send(prepareUploadRequest.files)
    }
    
    private func handleFileUpload(body: String) {
        // Implement file upload handling
    }
    
    private func createAcceptUploadResponse() -> P2PServerResponse {
        let transmissionId = UUID().uuidString
        self.transmissionId = transmissionId
        let response = PrepareUploadResponse(transmissionID: transmissionId)
        
        guard let responseData = response.buildResponse() else {
            return createErrorResponse(.internalServerError)
        }
        
        return P2PServerResponse(dataResponse: responseData, response: .success)
    }
    
    private func createRejectUploadResponse() -> P2PServerResponse {
        createErrorResponse(.forbidden)
    }
    
    private func createErrorResponse(_ error: HTTPError) -> P2PServerResponse {
        P2PServerResponse(dataResponse: error.buildErrorResponse(), response: .failure)
    }
    
    // MARK: - Response Handling
    
    private func handleServerResponse(_ serverResponse: P2PServerResponse?) {
        guard let serverResponse = serverResponse else {
            sendInternalServerError()
            return
        }
        
        sendDataToConnection(serverResponse: serverResponse)
    }
    
    private func sendInternalServerError() {
        let response = createErrorResponse(.internalServerError)
        sendDataToConnection(serverResponse: response)
    }
    
    private func sendDataToConnection(serverResponse: P2PServerResponse) {
        guard let connection = currentConnection else {
            debugLog("No active connection to send data")
            return
        }
        
        guard let data = serverResponse.dataResponse else {
            debugLog("No data to send in server response")
            return
        }
        
        connection.send(content: data, completion: .contentProcessed { [weak self] error in
            if let error = error {
                debugLog("Server send error: \(error)")
                return
            }
            
            self?.handleSuccessfulResponse(serverResponse)
        })
    }
    
    private func handleSuccessfulResponse(_ serverResponse: P2PServerResponse) {
        guard let endpoint = currentHTTPRequest?.endpoint else {
            debugLog("No endpoint found in current HTTP response")
            return
        }
        
        let isSuccess = serverResponse.response == .success
        
        switch PeerToPeerEndpoint(rawValue: endpoint) {
        case .register:
            didRegisterPublisher.send(isSuccess)
        case .prepareUpload:
            didSendPrepareUploadResponsePublisher.send(isSuccess)
        default:
            debugLog("Unhandled endpoint: \(endpoint)")
        }
        
        debugLog("Server successfully sent response for endpoint: \(endpoint)")
    }
    
    // MARK: - File Handling
    
    private func saveFile(data: Data, fileName: String) throws {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "PeerToPeerServer", code: HTTPError.internalServerError.rawValue,
                          userInfo: [NSLocalizedDescriptionKey: "Documents directory not found"])
        }
        
        let fileURL = documentsURL.appendingPathComponent(fileName)
        try data.write(to: fileURL)
        debugLog("File saved to: \(fileURL.path)")
    }
    
    private func resetConnectionState() {
        currentConnection = nil
        currentHTTPRequest = nil
        fileData = Data()
        contentLength = nil
        failedAttempts = 0
        hasTLSError = false
    }
}

// MARK: - Supporting Types

enum PeerToPeerEndpoint: String {
    case register = "/api/v1/register"
    case prepareUpload = "/api/v1/prepare-upload"
    case upload = "/api/v1/upload"
    case closeConnection = "/api/v1/close-connection"
}

struct P2PServerResponse {
    let dataResponse: Data?
    let response: ServerResponseStatus
}

enum ServerResponseStatus {
    case success
    case failure
}

enum HTTPError: Int, Error {
    case internalServerError = 500
    case notFound = 404
    case unauthorized = 401
    case badRequest = 400
    case forbidden = 403
    case conflict = 409
    case tooManyRequests = 429
    
    var message: String {
        switch self {
        case .internalServerError: return "Internal Server Error"
        case .notFound: return "Not Found"
        case .unauthorized: return "Unauthorized"
        case .badRequest: return "Invalid request format"
        case .forbidden: return "Rejected"
        case .conflict: return "Active session already exists"
        case .tooManyRequests: return "Too many requests"
        }
    }
}

extension PeerToPeerServer {
    static func stub() -> PeerToPeerServer {
        return PeerToPeerServer()
    }
}
