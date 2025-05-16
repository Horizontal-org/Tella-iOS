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

class PeerToPeerServer {
    
    private var listener: NWListener?
    
    var fileData = Data()
    var contentLength : Int?
    var pin : String?
    var sessionId : String?
    var transmissionId : String?
    var requestsNumber : Int = 0
    
    var didRegisterPublisher = PassthroughSubject<Void, Never>()
    var didRequestRegisterPublisher = PassthroughSubject<Void, Never>()
    var didCancelAuthenticationPublisher = PassthroughSubject<Void, Never>()
    var didReceivePrepareUploadPublisher = PassthroughSubject<[P2PFile], Never>()
    var didSendPrepareUploadResponsePublisher = PassthroughSubject<Void, Never>()
    var didReceiveErrorPublisher = PassthroughSubject<Void, Never>()
    // var didReceiveFilesPublisher = PassthroughSubject<Data, Never>()
    // var didTimeoutPublisher = PassthroughSubject<Void, Never>()
    
    private var registerBody: String?
    private var hasTLSError: Bool = false
    private var currentConnection: NWConnection?
    private var currentHTTPResponse: HTTPResponse?
    
    func startListening(port : Int, pin : String, clientIdentity:SecIdentity) {
        self.pin = pin
        let port: NWEndpoint.Port = .init(integerLiteral: UInt16(port))
        let tlsOptions = NWProtocolTLS.Options()
        let parameters = NWParameters(tls: tlsOptions)
        
        do {
            
            sec_protocol_options_set_local_identity (tlsOptions.securityProtocolOptions, sec_identity_create(clientIdentity)!)
            
            sec_protocol_options_set_challenge_block(tlsOptions.securityProtocolOptions, { (_, completionHandler) in
                completionHandler(sec_identity_create(clientIdentity)!)
            }, .main)
            
            self.listener = try NWListener(using: parameters, on: port)
            
            self.listener?.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    debugLog("Listener is ready and waiting for connections.")
                case .failed(let error):
                    debugLog("Listener failed: \(error.localizedDescription)")
                case .cancelled:
                    debugLog("Listener cancelled.")
                default:
                    break
                }
            }
            
            self.listener?.newConnectionHandler = { [weak self] connection in
                connection.start(queue: .main)
                DispatchQueue.global(qos: .userInitiated).async {
                    self?.currentConnection = connection
                    self?.startReceive(on: connection)
                }
            }
            
            self.listener?.start(queue: .main)
            
        } catch {
            debugLog("Failed to create listener: \(error.localizedDescription)")
        }
    }
    
    private func startReceive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { data, _, _, error in
            if let error = error {
                debugLog("Error: \(error)")
                if case .tls(let tlsErrorCode) = error {
                    debugLog("TLS Error: \(tlsErrorCode)")
                    self.didCancelAuthenticationPublisher.send()
                    self.hasTLSError = true
                }
                return
            }
            
            guard let data = data, let raw = data.utf8String()else {
                debugLog("Failed to read HTTP data.")
                return
            }
            
            debugLog("Received HTTP Request:\n\(raw)")
            
            guard let httpResponse = raw.parseHTTPResponse() else {
                debugLog("Failed to parse the HTTPResponse ")
                return
            }
            
            self.currentHTTPResponse = httpResponse
            guard let expectedLength = httpResponse.headers.contentLength else {
                debugLog("Content-Length header missing")
                return
            }
            let body = httpResponse.body
            // Check if full body is received
            if body.utf8.count < expectedLength {
                debugLog("Body incomplete, waiting for more (\(body.utf8.count)/\(expectedLength))")
                
                // Store current partial body, read more
                let remaining = expectedLength - body.utf8.count
                self.receiveRemainingBody(on: connection, httpResponse: httpResponse, expectedLength: expectedLength, remaining: remaining)
            } else {
                debugLog("Full JSON Body: \(body)")
                self.processReceivedData(connection: connection, fullBody: body, httpResponse: httpResponse)
            }
        }
    }
    
    private func receiveRemainingBody(on connection: NWConnection, httpResponse: HTTPResponse, expectedLength: Int, remaining: Int) {
        connection.receive(minimumIncompleteLength: remaining, maximumLength: remaining) { data, _, _, error in
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
            
            self.processReceivedData(connection: connection, fullBody: fullBody, httpResponse: httpResponse)
        }
    }
    
    private func processReceivedData(connection:NWConnection, fullBody:String, httpResponse:HTTPResponse) {
        
        let endpoint = httpResponse.endpoint
        
        switch PeerToPeerEndpoint(rawValue: endpoint ) {
        case .register: handleRegisterRequest()
        case .prepareUpload: handlePrepareUploadRequest(body: fullBody)
        case .upload:
            break
        default:
            break
        }
    }
    
    private func handleRegisterRequest() {
        if hasTLSError {
            didRequestRegisterPublisher.send()
        } else {
            let serverResponse = self.generateRegisterServerResponse()
            handleServerResponse(serverResponse)
        }
    }
    
    private func generateRegisterServerResponse() -> P2PServerResponse? {
        /*
         HTTP code     Message
         400           Invalid request format
         401           Invalid PIN
         403           Invalid encryption/decryption ❌
         409           Active session already exists
         429           Too many requests
         500           Server error
         */
        
        guard
            let body = currentHTTPResponse?.body,
            let registerRequest = body.decodeJSON(RegisterRequest.self)
        else {
            let data = HTTPError.badRequest.buildErrorResponse()
            return P2PServerResponse(dataResponse: data, response: .failure)
        }
        
        debugLog(body)
        
        if requestsNumber >= 3 {
            let data = HTTPError.tooManyRequests.buildErrorResponse()
            return P2PServerResponse(dataResponse: data, response: .failure)
        }
        
        if sessionId != nil {
            let data = HTTPError.conflict.buildErrorResponse()
            return P2PServerResponse(dataResponse: data, response: .failure)
        }
        
        if pin != registerRequest.pin {
            requestsNumber += 1
            let data = HTTPError.unauthorized.buildErrorResponse()
            return P2PServerResponse(dataResponse: data, response: .failure)
        }
        
        let sessionId = UUID().uuidString
        self.sessionId = sessionId
        let response = RegisterResponse(sessionId: sessionId)
        
        guard let responseData = response.buildResponse() else {
            return nil
        }
        
        return P2PServerResponse(dataResponse: responseData, response: .success)
    }
    
    func acceptRegisterRequest() {
        let serverResponse = self.generateRegisterServerResponse()
        handleServerResponse(serverResponse)
    }
    
    private func handlePrepareUploadRequest(body: String?) {
        /*
         HTTP code    Message
         400    Invalid request format ✅
         401    Invalid session ID ✅
         403    Rejected ✅
         500    Server error ✅
         */
        //409    Blocked by another session? ❌
        
        guard
            let body,
            let prepareUploadRequest = body.decodeJSON(PrepareUploadRequest.self)
        else {
            let errorData = HTTPError.badRequest.buildErrorResponse()
            let error = P2PServerResponse(dataResponse: errorData, response: .failure)
            self.handleServerResponse(error)
            didReceiveErrorPublisher.send()
            return
        }
        
        if prepareUploadRequest.sessionID != sessionId {
            let errorData = HTTPError.unauthorized.buildErrorResponse()
            let error = P2PServerResponse(dataResponse: errorData, response: .failure)
            self.handleServerResponse(error)
            didReceiveErrorPublisher.send()
            return
        }
        
        didReceivePrepareUploadPublisher.send(prepareUploadRequest.files)
    }
    
    func sendPrepareUploadFiles(filesAccepted:Bool) {
        
        var serverResponse : P2PServerResponse?
        if filesAccepted {
            let response = PrepareUploadResponse(transmissionID: UUID().uuidString)
            let responseData = response.buildResponse()
            serverResponse = P2PServerResponse(dataResponse: responseData, response: .success)
        } else {
            let data = HTTPError.forbidden.buildErrorResponse()
            serverResponse = P2PServerResponse(dataResponse: data, response: .failure)
        }
        self.handleServerResponse(serverResponse)
    }
    
    private func handleUploadRequest(data: Data, endpoint: String?, error: Error?, connection: NWConnection) -> P2PServerResponse? {
        /*
         HTTP code    Message
         400    Missing required parameters
         401    Invalid session ID
         403    Invalid transmission ID
         409    Transfer already completed
         413    File too large
         415    Unsupported file type
         507    Insufficient storage space
         500    Server error
         */
        
        if !data.isEmpty && endpoint != nil {
            self.fileData.append(data)
        }
        
        if let contentLength = self.contentLength, contentLength <= self.fileData.count {
            return self.finalizeUpload(connection: connection)
        } else if let error = error {
            debugLog("Error receiving data: \(error)")
        } else {
            debugLog("Continue receiving data")
            //            self.receive(on: connection, specifiedEndpoint: "/api/localsend/v2/upload")
        }
        return nil
    }
    
    private func handleCloseConnectionRequest() -> P2PServerResponse? {
        
        /*
         HTTP code    Message
         400    Missing session ID
         401    Invalid session ID
         403    Session already closed
         500    Server error
         */
        return nil
    }
    
    private func finalizeUpload(connection: NWConnection) -> P2PServerResponse? {
        debugLog("File transfer completed")
        
        self.saveFile(data: self.fileData)
        
        self.fileData = Data()
        self.stopListening()
        self.contentLength = nil
        
        let response = BoolResponse(success:true)
        let  responseData = response.buildResponse()
        
        return P2PServerResponse(dataResponse: responseData, response: .success)
    }
    
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
        
        let dataResponse = P2PServerResponse(dataResponse: data, response: .failure)
        sendDataToConnection(serverResponse: dataResponse)
    }
    
    private func sendDataToConnection(serverResponse: P2PServerResponse) {
        guard let currentConnection else {
            debugLog("No active connection to send data.")
            return
        }
        
        currentConnection.send(content: serverResponse.dataResponse, completion: .contentProcessed { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                debugLog("Server send error: \(error)")
                return
            }
            self.handleSuccessResponse(for: serverResponse)
        })
    }
    
    private func handleSuccessResponse(for serverResponse: P2PServerResponse) {
        guard serverResponse.response == .success else {
            debugLog("Response not marked as success.")
            return
        }
        
        guard let endpoint = self.currentHTTPResponse?.endpoint else {
            debugLog("No endpoint found in current HTTP response.")
            return
        }
        
        switch PeerToPeerEndpoint(rawValue: endpoint) {
        case .register: self.didRegisterPublisher.send()
        case .prepareUpload: self.didSendPrepareUploadResponsePublisher.send()
        default:
            debugLog("Unhandled endpoint: \(endpoint)")
        }
        
        debugLog("Server successfully sent response for endpoint: \(endpoint)")
    }
    
    func stopListening() {
        listener?.cancel()
    }
    
    func saveFile(data: Data) {
        // Define the file path (e.g., in the Documents directory)
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("downloadedFile.png")
        
        do {
            // Write the received data to the file
            try data.write(to: fileURL)
            debugLog("File saved to: \(fileURL.path)")
            debugLog("File data received completed completed completed completed: \(self.fileData.count) bytes  \n\n\n\n\n\n\n\n \(fileURL)")
            
        } catch {
            debugLog("Failed to save file: \(error)")
        }
    }
}

enum PeerToPeerEndpoint : String {
    case register = "/api/v1/register"
    case prepareUpload = "/api/v1/prepare-upload"
    case upload = "/api/v1/upload"
    case closeConnection = "/api/v1/close-connection"
    case none = ""
}

struct P2PServerResponse {
    var dataResponse : Data?
    var response : ServerResponseStatus
}

enum ServerResponseStatus {
    case success
    case failure
}

extension PeerToPeerServer {
    
    static func stub() -> PeerToPeerServer {
        return PeerToPeerServer()
    }
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
