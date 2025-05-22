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
    private let networkManager = NetworkManager()
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
    let didRegisterManuallyPublisher = PassthroughSubject<Bool, Never>()
    let didRequestRegisterPublisher = PassthroughSubject<Void, Never>()
    let didCancelAuthenticationPublisher = PassthroughSubject<Void, Never>()
    let didReceivePrepareUploadPublisher = PassthroughSubject<[P2PFile], Never>()
    let didSendPrepareUploadResponsePublisher = PassthroughSubject<Bool, Never>()
    let didReceiveCloseConnectionPublisher = PassthroughSubject<Void, Never>()
    
    init() {
        networkManager.delegate = self
    }
    
    // MARK: - Server Lifecycle
    func startListening(port: Int, pin: String, clientIdentity: SecIdentity) {
        self.pin = pin
        networkManager.startListening(port: port, pin: pin, clientIdentity: clientIdentity)
    }
    
    func stopListening() {
        networkManager.stopListening()
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
    
    // MARK: - Request Processing
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
            handleCloseConnectionRequest(body: body)
        }
    }
    
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
    
    func handleCloseConnectionRequest(body: String) {
        do {
            let serverResponse = try generateCloseConnectionResponse(body: body)
            handleServerResponse(serverResponse)
        } catch let error as HTTPError {
            handleServerResponse(createErrorResponse(error))
        } catch {
            sendInternalServerError()
        }
    }
    
    private func generateCloseConnectionResponse(body: String) throws -> P2PServerResponse {
        guard let closeConnectionRequest = body.decodeJSON(CloseConnectionRequest.self) else {
            throw HTTPError.badRequest
        }
        
        guard closeConnectionRequest.sessionID == sessionId else {
            throw HTTPError.unauthorized
        }
        
        let response = BoolResponse(success: true)
        
        guard let responseData = response.buildResponse() else {
            throw HTTPError.internalServerError
        }
        
        return P2PServerResponse(dataResponse: responseData, response: .success)
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
        guard let data = serverResponse.dataResponse else {
            debugLog("No data to send in server response")
            return
        }
        
        networkManager.sendData(data) { [weak self] error in
            if error == nil {
                self?.handleSuccessfulResponse(serverResponse)
            }
        }
    }
    
    private func handleSuccessfulResponse(_ serverResponse: P2PServerResponse) {
        guard let endpoint = currentHTTPRequest?.endpoint else {
            debugLog("No endpoint found in current HTTP response")
            return
        }
        
        let isSuccess = serverResponse.response == .success
        
        switch PeerToPeerEndpoint(rawValue: endpoint) {
        case .register:
            hasTLSError ? didRegisterManuallyPublisher.send(isSuccess) : didRegisterPublisher.send(isSuccess)
        case .prepareUpload:
            didSendPrepareUploadResponsePublisher.send(isSuccess)
        case .closeConnection:
            didReceiveCloseConnectionPublisher.send()
            stopListening()
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
        currentHTTPRequest = nil
        fileData = Data()
        contentLength = nil
        failedAttempts = 0
        hasTLSError = false
    }
}

extension PeerToPeerServer: NetworkManagerDelegate {
    func networkManagerDidStopListening(_ manager: NetworkManager) {
        
    }
    
    func networkManager(_ manager: NetworkManager, didFailWith error: any Error) {
        
    }
    
    func networkManagerDidEncounterTLSError(_ manager: NetworkManager) {
        didCancelAuthenticationPublisher.send()
        hasTLSError = true
    }
    
    func networkManager(_ manager: NetworkManager, didReceiveCompleteRequest request: HTTPRequest) {
        currentHTTPRequest = request
        processCompleteBody(request.body, httpRequest: request)
    }
    
    func networkManagerDidStartListening(_ manager: NetworkManager) {
        debugLog("Network manager started listening")
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
