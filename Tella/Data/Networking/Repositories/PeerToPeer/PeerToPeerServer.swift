//
//  PeerToPeerServer.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/3/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
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
    //    var didPrepareUploadPublisher = PassthroughSubject<Data, Never>()
    //    var didReceiveFilesPublisher = PassthroughSubject<Data, Never>()
    //    var didTimeoutPublisher = PassthroughSubject<Void, Never>()
    
    
    func startListening(port : Int, pin : String) {
        self.pin = pin
        let port: NWEndpoint.Port = .init(integerLiteral: UInt16(port))
        let tlsOptions = NWProtocolTLS.Options()
        let parameters = NWParameters(tls: tlsOptions)
        let certificateFile = FileManager.tempDirectory(withFileName: "certificate.p12")
        
        do {
            
            if let clientIdentity = certificateFile?.loadCertificate() {
                
                sec_protocol_options_set_local_identity(tlsOptions.securityProtocolOptions, sec_identity_create(clientIdentity)!)
                
                sec_protocol_options_set_challenge_block(tlsOptions.securityProtocolOptions, { (_, completionHandler) in
                    completionHandler(sec_identity_create(clientIdentity)!)
                }, .main)
                
                let listener = try NWListener(using: parameters, on: port)
                
                listener.stateUpdateHandler = { state in
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
                
                listener.newConnectionHandler = { [weak self] connection in
                    connection.start(queue: .main)
                    self?.receive(on: connection)
                }
                
                listener.start(queue: .main)
                
            } else {
                debugLog("Failed to load TLS identity")
            }
            
        } catch {
            debugLog("Failed to create listener: \(error.localizedDescription)")
        }
    }
    
    private func receive(on nwConnection: NWConnection, specifiedEndpoint: String? = nil) {
        
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 1024 * 1024) { receivedData, _, isComplete, error in
            if let receivedData, !receivedData.isEmpty {
                
                let responseString = receivedData.string()
                let httpResponse = responseString.parseHTTPResponse()
                let endpoint = specifiedEndpoint ?? httpResponse?.endpoint
                
                self.handleParsedHeaders(httpResponse)
                
                var dataResponse: ServerResponse?
                
                switch PeerToPeerEndpoint(rawValue: endpoint ?? "") {
                case .register:
                    dataResponse = self.handleRegisterRequest(body: httpResponse?.body)
                    
                case .prepareUpload:
                    dataResponse = self.handlePrepareUploadRequest()
                    
                case .upload:
                    dataResponse = self.handleUploadRequest(data: receivedData, endpoint: endpoint, error: error, connection: nwConnection)
                    
                default:
                    break
                }
                
                if let dataResponse = dataResponse {
                    self.sendResponse(connection: nwConnection, serverResponse: dataResponse)
                }
            }
        }
    }
    
    private func handleParsedHeaders(_ parsed: HTTPResponse?) {
        if let length = parsed?.headers.contentLength, let lengthInt = Int(length) {
            self.contentLength = lengthInt
        }
    }
    
    private func handleRegisterRequest(body: String?) -> ServerResponse? {
        /*
         HTTP code     Message
         400           Invalid request format
         401           Invalid PIN ✅
         403           Invalid encryption/decryption ? ❌
         409           Active session already exists ✅
         429           Too many requests ✅
         500           Server error ✅
         */

        guard
            let body,
            let registerRequest = body.decodeJSON(RegisterRequest.self)
        else {
            let data = HTTPResponseBuilder.buildErrorResponse(
                error: "Invalid request format",
                statusCode: HTTPErrorCodes.badRequest.rawValue
            )
            return data.map { ServerResponse(dataResponse: $0, response: .failure) }
        }
        
        if requestsNumber >= 3 {
            let data = HTTPResponseBuilder.buildErrorResponse(
                error: "Too many requests",
                statusCode: HTTPErrorCodes.tooManyRequests.rawValue
            )
            return data.map { ServerResponse(dataResponse: $0, response: .failure) }
        }
        
        if sessionId != nil {
            let data = HTTPResponseBuilder.buildErrorResponse(
                error: "Active session already exists",
                statusCode: HTTPErrorCodes.conflict.rawValue
            )
            return data.map { ServerResponse(dataResponse: $0, response: .failure) }
        }
        
        if pin != registerRequest.pin {
            requestsNumber += 1
            let data = HTTPResponseBuilder.buildErrorResponse(
                error: "Invalid PIN",
                statusCode: HTTPErrorCodes.unauthorized.rawValue
            )
            return data.map { ServerResponse(dataResponse: $0, response: .failure) }
        }
        
        let sessionId = UUID().uuidString
        self.sessionId = sessionId
        let response = RegisterResponse(sessionId: sessionId)
        
        guard let responseData = HTTPResponseBuilder.buildResponse(body: response) else {
            return nil
        }
        
        return ServerResponse(dataResponse: responseData, response: .success)
    }
    
    private func handlePrepareUploadRequest() -> ServerResponse? {
        /*
         HTTP code    Message
         400    Invalid request format
         401    Invalid session ID
         403    Session expired
         500    Server error
         */
        
        let response = PrepareUploadResponse(transmissionID: UUID().uuidString)
        let responseData =  HTTPResponseBuilder.buildResponse(body: response)
        
        return ServerResponse(dataResponse: responseData, response: .success)
        
    }
    
    private func handleUploadRequest(data: Data, endpoint: String?, error: Error?, connection: NWConnection) -> ServerResponse? {
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
            self.receive(on: connection, specifiedEndpoint: "/api/localsend/v2/upload")
        }
        
        return nil
    }
    
    private func handleCloseConnectionRequest() -> ServerResponse? {
        
        /*
         HTTP code    Message
         400    Missing session ID
         401    Invalid session ID
         403    Session already closed
         500    Server error
         */
        return nil
    }
    
    private func finalizeUpload(connection: NWConnection) -> ServerResponse? {
        debugLog("File transfer completed")
        
        self.saveFile(data: self.fileData)
        
        self.fileData = Data()
        self.stopListening()
        self.contentLength = nil
        
        let response = BoolResponse(success:true)
        let  responseData = HTTPResponseBuilder.buildResponse(body: response)
        
        return ServerResponse(dataResponse: responseData, response: .success)
        
    }
    
    private func sendResponse(connection: NWConnection, serverResponse: ServerResponse) {
        connection.send(content: serverResponse.dataResponse, completion: .contentProcessed { error in
            if let error = error {
                debugLog("Server send error: \(error)")
            } else {
                if serverResponse.response == .success {
                    self.didRegisterPublisher.send()
                }
                debugLog("Server sent response")
            }
        })
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
    case none = ""
}

struct ServerResponse {
    var dataResponse : Data?
    var response : ServerResponseStatus
}

enum ServerResponseStatus {
    case success
    case failure
}
