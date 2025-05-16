//
//  PeerToPeerServer.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Network
import SwiftUICore
import Combine

import Network
import SwiftUICore
import Combine
import os.log

class PeerToPeerServer {
    
    // MARK: - Properties
    
    private var listener: NWListener?
    private var currentConnection: NWConnection?
    private var currentHTTPResponse: HTTPResponse?
    private var hasTLSError = false
    private var requestsNumber = 0

    // Server state
    var fileData = Data()
    var contentLength: Int?
    var pin: String?
    var sessionId: String?
    var transmissionId: String?
    
    // Publishers
    let didRegisterPublisher = PassthroughSubject<Void, Never>()
    let didRequestRegisterPublisher = PassthroughSubject<Void, Never>()
    let didCancelAuthenticationPublisher = PassthroughSubject<Void, Never>()
    let didReceivePrepareUploadPublisher = PassthroughSubject<[P2PFile], Never>()
    let didSendPrepareUploadResponsePublisher = PassthroughSubject<Void, Never>()
    let didReceiveErrorPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Server Lifecycle
    
    func startListening(port: Int, pin: String, clientIdentity: SecIdentity) {
        self.pin = pin
        
        do {
            let parameters = try createNetworkParameters(port: port, clientIdentity: clientIdentity)
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
        let serverResponse = generateRegisterServerResponse()
        handleServerResponse(serverResponse)
    }
    
    func sendPrepareUploadFiles(filesAccepted: Bool) {
        let serverResponse = filesAccepted ? createAcceptUploadResponse() : createRejectUploadResponse()
        handleServerResponse(serverResponse)
    }
    
    // MARK: - Private Methods
    
    private func createNetworkParameters(port: Int, clientIdentity: SecIdentity) throws -> NWParameters {
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
            connection.start(queue: .main)
            DispatchQueue.global(qos: .userInitiated).async {
                self?.currentConnection = connection
                self?.startReceive(on: connection)
            }
        }
    }
    
    private func startReceive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, _, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleReceiveError(error)
                return
            }
            
            guard let data = data, let raw = data.utf8String()else {
                debugLog("Failed to read HTTP data")
                return
            }
            
            debugLog("Received HTTP Request:\n\(raw)")
            
            guard let httpResponse = raw.parseHTTPResponse() else {
                debugLog("Failed to parse the HTTPResponse")
                return
            }
            
            self.processHTTPResponse(httpResponse, on: connection)
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
    
    private func processHTTPResponse(_ httpResponse: HTTPResponse, on connection: NWConnection) {
        currentHTTPResponse = httpResponse
        
        guard let expectedLength = httpResponse.headers.contentLength else {
            debugLog("Content-Length header missing")
            return
        }
        
        let body = httpResponse.body
        if body.utf8.count < expectedLength {
            debugLog("Body incomplete, waiting for more (\(body.utf8.count)/\(expectedLength))")
            receiveRemainingBody(on: connection, httpResponse: httpResponse,
                                 expectedLength: expectedLength, remaining: expectedLength - body.utf8.count)
        } else {
            debugLog("Full JSON Body: \(body)")
            processCompleteBody(body, httpResponse: httpResponse, connection: connection)
        }
    }
    
    private func receiveRemainingBody(on connection: NWConnection, httpResponse: HTTPResponse,
                                     expectedLength: Int, remaining: Int) {
        connection.receive(minimumIncompleteLength: remaining, maximumLength: remaining) { [weak self] data, _, _, error in
            guard let self = self else { return }
            
            if let error = error {
                debugLog("Error receiving remaining body: \(error)")
                return
            }
            
            guard let data = data, let more = data.utf8String() else {
                debugLog("Failed to decode remaining data")
                return
            }
            
            let fullBody = httpResponse.body + more
            debugLog("Full JSON Body after completion: \(fullBody)")
            self.currentHTTPResponse?.body = fullBody
            
            self.processCompleteBody(fullBody, httpResponse: httpResponse, connection: connection)
        }
    }
    
    private func processCompleteBody(_ body: String, httpResponse: HTTPResponse, connection: NWConnection) {
        guard let endpoint = PeerToPeerEndpoint(rawValue: httpResponse.endpoint) else {
            debugLog("Unknown endpoint: \(httpResponse.endpoint)")
            return
        }
        
        switch endpoint {
        case .register:
            handleRegisterRequest()
        case .prepareUpload:
            handlePrepareUploadRequest(body: body)
        case .upload:
            break // Implement upload handling as needed
        case .closeConnection:
            break // Implement close connection handling as needed
        case .none:
            debugLog("Empty endpoint received")
        }
    }
    
    // MARK: - Request Processing
    
    private func handleRegisterRequest() {
        if hasTLSError {
            didRequestRegisterPublisher.send()
        } else {
            let serverResponse = generateRegisterServerResponse()
            handleServerResponse(serverResponse)
        }
    }
    
    private func generateRegisterServerResponse() -> P2PServerResponse? {
        guard let body = currentHTTPResponse?.body,
              let registerRequest = body.decodeJSON(RegisterRequest.self) else {
            return createErrorResponse(.badRequest)
        }
        
        debugLog("Register request body: \(body)")
        
        if requestsNumber >= 3 {
            return createErrorResponse(.tooManyRequests)
        }
        
        if sessionId != nil {
            return createErrorResponse(.conflict)
        }
        
        guard pin == registerRequest.pin else {
            requestsNumber += 1
            return createErrorResponse(.unauthorized)
        }
        
        let sessionId = UUID().uuidString
        self.sessionId = sessionId
        let response = RegisterResponse(sessionId: sessionId)
        
        guard let responseData = response.buildResponse() else {
            return nil
        }
        
        return P2PServerResponse(dataResponse: responseData, response: .success)
    }
    
    private func handlePrepareUploadRequest(body: String?) {
        guard let body,
              let prepareUploadRequest = body.decodeJSON(PrepareUploadRequest.self) else {
            handleServerResponse(createErrorResponse(.badRequest))
            didReceiveErrorPublisher.send()
            return
        }
        
        guard prepareUploadRequest.sessionID == sessionId else {
            handleServerResponse(createErrorResponse(.unauthorized))
            didReceiveErrorPublisher.send()
            return
        }
        
        didReceivePrepareUploadPublisher.send(prepareUploadRequest.files)
    }
    
    private func createAcceptUploadResponse() -> P2PServerResponse? {
        let response = PrepareUploadResponse(transmissionID: UUID().uuidString)
        guard let responseData = response.buildResponse() else { return nil }
        return P2PServerResponse(dataResponse: responseData, response: .success)
    }
    
    private func createRejectUploadResponse() -> P2PServerResponse {
        let data = HTTPError.forbidden.buildErrorResponse()
        return P2PServerResponse(dataResponse: data, response: .failure)
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
        guard let data = HTTPError.internalServerError.buildErrorResponse() else {
            debugLog("Failed to build error response.")
            return
        }
        sendDataToConnection(serverResponse: P2PServerResponse(dataResponse: data, response: .failure))
    }
    
    private func sendDataToConnection(serverResponse: P2PServerResponse) {
        guard let currentConnection else {
            debugLog("No active connection to send data")
            return
        }
        
        guard let data = serverResponse.dataResponse else {
            debugLog("No data to send in server response")
            return
        }
        
        currentConnection.send(content: data, completion: .contentProcessed { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                debugLog("Server send error: \(error)")
                return
            }
            
            self.handleSuccessfulResponse(serverResponse)
        })
    }
    
    private func handleSuccessfulResponse(_ serverResponse: P2PServerResponse) {
        guard serverResponse.response == .success else {
            debugLog("Response not marked as success.")
            return
        }
        
        guard let endpoint = self.currentHTTPResponse?.endpoint else {
            debugLog("No endpoint found in current HTTP response.")
            return
        }
        
        switch PeerToPeerEndpoint(rawValue: endpoint) {
        case .register:
            didRegisterPublisher.send()
        case .prepareUpload:
            didSendPrepareUploadResponsePublisher.send()
        default:
            debugLog("Unhandled endpoint: \(endpoint)")
        }
        
        debugLog("Server successfully sent response for endpoint: \(endpoint)")
    }
    
    // MARK: - File Handling
    
    private func saveFile(data: Data) {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            debugLog("Could not access documents directory")
            return
        }
        
        let fileURL = documentsURL.appendingPathComponent("downloadedFile.png")
        
        do {
            try data.write(to: fileURL)
            debugLog("File saved to: \(fileURL.path)")
        } catch {
            debugLog("Failed to save file: \(error)")
        }
    }
    
    private func resetConnectionState() {
        currentConnection = nil
        currentHTTPResponse = nil
        fileData = Data()
        contentLength = nil
    }
}

// MARK: - Supporting Types

enum PeerToPeerEndpoint: String {
    case register = "/api/v1/register"
    case prepareUpload = "/api/v1/prepare-upload"
    case upload = "/api/v1/upload"
    case closeConnection = "/api/v1/close-connection"
    case none = ""
}

struct P2PServerResponse {
    let dataResponse: Data?
    let response: ServerResponseStatus
}

enum ServerResponseStatus {
    case success
    case failure
}

enum HTTPError: Int {
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
        case .forbidden: return "Forbidden"
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
