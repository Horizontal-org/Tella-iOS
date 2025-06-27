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
    private var server = P2PServerState()
    
    // Publishers
    let didRegisterPublisher = PassthroughSubject<Bool, Never>()
    let didRegisterManuallyPublisher = PassthroughSubject<Bool, Never>()
    let didRequestRegisterPublisher = PassthroughSubject<Void, Never>()
    let showVerificationHashPublisher = PassthroughSubject<Void, Never>()
    let didReceivePrepareUploadPublisher = PassthroughSubject<[P2PFile]?, Never>()
    let didSendPrepareUploadResponsePublisher = PassthroughSubject<Bool, Never>()
    let didReceiveCloseConnectionPublisher = PassthroughSubject<Void, Never>()
    
    init() {
        networkManager.delegate = self
    }
    
    // MARK: - Server Lifecycle
    func startListening(port: Int, pin: String, clientIdentity: SecIdentity) {
        server.pin = pin
        networkManager.startListening(port: port, clientIdentity: clientIdentity)
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
        } catch let error as HTTPStatusCode {
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
    private func processCompleteBody(httpRequest: HTTPRequest, completion: ((URL)-> Void)? = nil) {
        guard let endpoint = PeerToPeerEndpoint(rawValue: httpRequest.endpoint) else {
            debugLog("Unknown endpoint")
            return
        }
        
        switch endpoint {
        case .ping:
            handlePingRequest()
        case .register:
            handleRegisterRequest()
        case .prepareUpload:
            handlePrepareUploadRequest(httpRequest: httpRequest)
        case .upload:
            handleFileUpload(httpRequest: httpRequest, completion: completion)
        case .closeConnection:
            handleCloseConnectionRequest(httpRequest: httpRequest)
        }
    }
    
    private func handlePingRequest() {
        showVerificationHashPublisher.send()
        server.isUsingManualConnection = true
        sendSuccessResponse()
    }
    
    private func sendSuccessResponse() {
        
        let response = BoolResponse(success: true)
        
        let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(response)
            .closeConnection()
            .build()
        
        if let responseData {
            let response = P2PServerResponse(dataResponse: responseData, response: .success)
            sendDataToConnection(serverResponse: response)
        }
    }
    
    private func handleRegisterRequest() {
        if server.isUsingManualConnection {
            didRequestRegisterPublisher.send()
        } else {
            do {
                let serverResponse = try generateRegisterServerResponse()
                handleServerResponse(serverResponse)
            } catch let error as HTTPStatusCode {
                handleServerResponse(createErrorResponse(error))
            } catch {
                sendInternalServerError()
            }
        }
    }
    
    private func generateRegisterServerResponse() throws -> P2PServerResponse {
        
        if server.session != nil {
            throw HTTPStatusCode.conflict
        }
        
        if server.hasReachedMaxAttempts {
            throw HTTPStatusCode.tooManyRequests
        }
        
        guard let body = currentHTTPRequest?.body,
              let registerRequest = body.decodeJSON(RegisterRequest.self) else {
            throw HTTPStatusCode.badRequest
        }
        
        guard server.pin == registerRequest.pin else {
            server.incrementFailedAttempts()
            if server.hasReachedMaxAttempts {
                throw HTTPStatusCode.tooManyRequests
            }
            throw HTTPStatusCode.unauthorized
        }
        
        let sessionId = UUID().uuidString
        let session = P2PSession(sessionId: sessionId)
        server.session = session
        
        let response = RegisterResponse(sessionId: sessionId)
        
        let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(response)
            .closeConnection()
            .build()
        
        guard let responseData else {
            throw HTTPStatusCode.internalServerError
        }
        
        return P2PServerResponse(dataResponse: responseData, response: .success)
    }
    
    private func handlePrepareUploadRequest(httpRequest: HTTPRequest) {
        guard let prepareUploadRequest = httpRequest.body.decodeJSON(PrepareUploadRequest.self) else {
            handleServerResponse(createErrorResponse(.badRequest))
            return
        }
        
        guard prepareUploadRequest.sessionID == server.session?.sessionId else {
            handleServerResponse(createErrorResponse(.unauthorized))
            return
        }
        
        prepareUploadRequest.files?.forEach({ file in
            guard let id = file.id else { return }
            server.session?.files[id] = ReceivingFile(file: file)
        })
        
        didReceivePrepareUploadPublisher.send(prepareUploadRequest.files)
    }
    
    private func handleFileUpload(httpRequest: HTTPRequest, completion:((URL)-> Void)? = nil) {
        do {
            let fileUploadRequest: FileUploadRequest = try httpRequest.queryParameters.decode(FileUploadRequest.self)
            
            guard let fileID = fileUploadRequest.fileID,
                  let transmissionID = fileUploadRequest.transmissionID,
                  let sessionID = fileUploadRequest.sessionID else {
                handleServerResponse(createErrorResponse(.badRequest))
                return
            }
            
            guard sessionID == server.session?.sessionId else {
                handleServerResponse(createErrorResponse(.unauthorized))
                return
            }
            
            guard let receivedFile = server.session?.files[fileID],
                  receivedFile.transmissionId == transmissionID,
                  let fileName = receivedFile.file.fileName
            else {
                handleServerResponse(createErrorResponse(.forbidden))
                return
            }
            
            if httpRequest.bodyFullyReceived {
                sendSuccessResponse()
            } else {
                let url = FileManager.tempDirectory(withFileName: fileName)
                completion?(url)
                return
            }
            
        } catch {
            
        }
    }
    
    func handleCloseConnectionRequest(httpRequest: HTTPRequest) {
        do {
            let serverResponse = try generateCloseConnectionResponse(body: httpRequest.body)
            handleServerResponse(serverResponse)
        } catch let error as HTTPStatusCode {
            handleServerResponse(createErrorResponse(error))
        } catch {
            sendInternalServerError()
        }
    }
    
    private func generateCloseConnectionResponse(body: String) throws -> P2PServerResponse {
        guard let closeConnectionRequest = body.decodeJSON(CloseConnectionRequest.self) else {
            throw HTTPStatusCode.badRequest
        }
        
        guard closeConnectionRequest.sessionID == server.session?.sessionId else {
            throw HTTPStatusCode.unauthorized
        }
        
        let response = BoolResponse(success: true)
        
        let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(response)
            .closeConnection()
            .build()
        
        guard let responseData else {
            return createErrorResponse(.internalServerError)
        }
        
        return P2PServerResponse(dataResponse: responseData, response: .success)
    }
    
    private func createAcceptUploadResponse() -> P2PServerResponse {
        
        var files : [P2PFileResponse] = []
        
        server.session?.files.forEach({ (key, value) in
            let transmeissionId = UUID().uuidString
            value.transmissionId = transmeissionId
            let fileResponse = P2PFileResponse(id: value.file.id, transmissionID: transmeissionId)
            files.append(fileResponse)
        })
        
        let response = PrepareUploadResponse(files: files)
        
        let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(response)
            .closeConnection()
            .build()
        
        guard let responseData else {
            return createErrorResponse(.internalServerError)
        }
        
        return P2PServerResponse(dataResponse: responseData, response: .success)
    }
    
    private func createRejectUploadResponse() -> P2PServerResponse {
        createErrorResponse(.forbidden)
    }
    
    private func createErrorResponse(_ error: HTTPStatusCode) -> P2PServerResponse {
        
        let response = ErrorMessage(error: error.reasonPhrase)
        
        let responseData = HTTPResponseBuilder(status: error)
            .setContentType(.json)
            .setBody(response)
            .closeConnection()
            .build()
        
        return P2PServerResponse(dataResponse: responseData, response: .failure)
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
            server.isUsingManualConnection ? didRegisterManuallyPublisher.send(isSuccess) : didRegisterPublisher.send(isSuccess)
        case .prepareUpload:
            didSendPrepareUploadResponsePublisher.send(isSuccess)
        case .closeConnection:
            didReceiveCloseConnectionPublisher.send()
            stopListening()
        default:
            debugLog("Unhandled endpoint")
        }
    }
    
    private func resetConnectionState() {
        currentHTTPRequest = nil
        server.reset()
    }
}

extension PeerToPeerServer: NetworkManagerDelegate {
    
    func networkManagerDidStopListening(_ manager: NetworkManager) {
    }
    
    func networkManager(_ manager: NetworkManager, didFailWith error: any Error) {
    }
    
    func networkManager(_ manager: NetworkManager, didReceiveCompleteRequest request: HTTPRequest) {
        currentHTTPRequest = request
        processCompleteBody(httpRequest: request)
    }
    
    func networkManager(_ manager: NetworkManager, verifyParametersForDataRequest request: HTTPRequest, completion: ((URL)-> Void)?) {
        currentHTTPRequest = request
        processCompleteBody(httpRequest: request, completion:completion)
    }
    
    func networkManager(_ manager: NetworkManager, didReceiveProgress request: HTTPRequest){
    }
    
    func networkManagerDidStartListening(_ manager: NetworkManager) {
        debugLog("Network manager started listening")
    }
}

extension PeerToPeerServer {
    static func stub() -> PeerToPeerServer {
        return PeerToPeerServer()
    }
}
