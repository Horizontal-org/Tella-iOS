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
    var server = P2PServerState()
    
    // Publishers
    let didFailStartServerPublisher = PassthroughSubject<Void, Never>()
    let didRegisterPublisher = PassthroughSubject<Bool, Never>()
    let didRegisterManuallyPublisher = PassthroughSubject<Bool, Never>()
    let didRequestRegisterPublisher = PassthroughSubject<Void, Never>()
    let showVerificationHashPublisher = PassthroughSubject<Void, Never>()
    let didReceivePrepareUploadPublisher = PassthroughSubject<[P2PFile]?, Never>()
    let didSendPrepareUploadResponsePublisher = PassthroughSubject<Bool, Never>()
    let didReceiveCloseConnectionPublisher = PassthroughSubject<Void, Never>()
    let didSendProgress = PassthroughSubject<P2PTransferredFile, Never>()
    let acceptRegisterPublisher = PassthroughSubject<Void, Never>()
    let discardRegisterPublisher = PassthroughSubject<Void, Never>()
    let prepareUploadPublisher = PassthroughSubject<Bool, Never>()
    
    var subscribers = Set<AnyCancellable>()
    
    init() {
        networkManager.delegate = self
    }
    
    // MARK: - Server Lifecycle
    func startListening(port: Int, pin: String, clientIdentity: SecIdentity) {
        server.pin = pin
        networkManager.startListening(port: port, clientIdentity: clientIdentity)
    }
    
    func stopServer() {
        networkManager.stopListening()
        resetConnectionState()
    }
    
    func cleanServer() {
        stopServer()
        cleanTempFiles()
    }
    
    func cleanTempFiles() {
        // Clean temp files
        guard let paths = server.session?.files.values.compactMap({$0.url}) else {
            return
        }
        paths.forEach({$0.remove()})
    }
    
    // MARK: - Request Handling
    func acceptRegisterRequest(connection: NWConnection) {
        do {
            let serverResponse = try generateRegisterServerResponse()
            handleServerResponse(connection: connection, serverResponse)
        } catch let error as HTTPStatusCode {
            handleServerResponse(connection: connection, createErrorResponse(error))
        } catch {
            sendInternalServerError(connection: connection)
        }
    }
    
    func discardRegisterRequest(connection: NWConnection) {
        handleServerResponse(connection: connection, createErrorResponse(.unauthorized))
    }
    
    func sendPrepareUploadFiles(connection: NWConnection, filesAccepted: Bool) {
        let serverResponse = filesAccepted ? createAcceptUploadResponse() : createRejectUploadResponse()
        handleServerResponse(connection: connection, serverResponse)
    }
    
    // MARK: - Request Processing
    private func processCompleteBody(connection: NWConnection, httpRequest: HTTPRequest, completion: ((URL)-> Void)? = nil) {
        guard let endpoint = PeerToPeerEndpoint(rawValue: httpRequest.endpoint) else {
            debugLog("Unknown endpoint")
            return
        }
        
        switch endpoint {
        case .ping:
            handlePingRequest(connection: connection)
        case .register:
            handleRegisterRequest(connection: connection)
        case .prepareUpload:
            handlePrepareUploadRequest(httpRequest: httpRequest, connection: connection)
        case .upload:
            handleFileUpload(connection: connection, httpRequest: httpRequest, completion: completion)
        case .closeConnection:
            handleCloseConnectionRequest(connection: connection, httpRequest: httpRequest)
        }
    }
    
    private func processProgress(connection: NWConnection, progress : Int, httpRequest: HTTPRequest) {
        do {
            let fileUploadRequest: FileUploadRequest = try httpRequest.queryParameters.decode(FileUploadRequest.self)
            
            guard let fileID = fileUploadRequest.fileID,
                  let progressFile = server.session?.files[fileID] else {
                handleServerResponse(connection: connection, createErrorResponse(.badRequest))
                return
            }
            progressFile.bytesReceived += progress
            
            server.session?.files[fileID] = progressFile
            
            didSendProgress.send(progressFile)
        } catch {
            
        }
    }
    
    private func handlePingRequest(connection: NWConnection) {
        showVerificationHashPublisher.send()
        server.isUsingManualConnection = true
        sendSuccessResponse(connection: connection)
    }
    
    private func sendSuccessResponse(connection: NWConnection) {
        
        let response = BoolResponse(success: true)
        
        let responseData = HTTPResponseBuilder()
            .setContentType(.json)
            .setBody(response)
            .closeConnection()
            .build()
        
        if let responseData {
            let response = P2PServerResponse(dataResponse: responseData, response: .success)
            sendDataToConnection(connection: connection, serverResponse: response)
        }
    }
    
    private func handleRegisterRequest(connection: NWConnection) {
        
        if server.isUsingManualConnection {
            didRequestRegisterPublisher.send()
            
            acceptRegisterPublisher
                .sink(receiveCompletion: { _ in
                    self.acceptRegisterRequest(connection: connection)
                }, receiveValue: { _ in
                }).store(in: &subscribers)
            
            discardRegisterPublisher
                .sink(receiveCompletion: { _ in
                    self.discardRegisterRequest(connection: connection)
                }, receiveValue: { _ in
                }).store(in: &subscribers)
        } else {
            do {
                let serverResponse = try generateRegisterServerResponse()
                handleServerResponse(connection: connection, serverResponse)
            } catch let error as HTTPStatusCode {
                handleServerResponse(connection: connection, createErrorResponse(error))
            } catch {
                sendInternalServerError(connection: connection)
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
    
    private func handlePrepareUploadRequest(httpRequest: HTTPRequest, connection: NWConnection) {
        guard let prepareUploadRequest = httpRequest.body.decodeJSON(PrepareUploadRequest.self) else {
            handleServerResponse(connection: connection, createErrorResponse(.badRequest))
            return
        }
        
        guard prepareUploadRequest.sessionID == server.session?.sessionId else {
            handleServerResponse(connection: connection, createErrorResponse(.unauthorized))
            return
        }
        
        server.session?.title = prepareUploadRequest.title
        
        prepareUploadRequest.files?.forEach({ file in
            guard let id = file.id else { return }
            server.session?.files[id] = P2PTransferredFile(file: file)
        })
        
        prepareUploadPublisher.sink { result in
        } receiveValue: { filesAccepted in
            self.sendPrepareUploadFiles(connection: connection, filesAccepted: filesAccepted)
        }.store(in: &subscribers)
        
        didReceivePrepareUploadPublisher.send(prepareUploadRequest.files)
        
    }
    
    private func handleFileUpload(connection: NWConnection,httpRequest: HTTPRequest, completion: ((URL)-> Void)? = nil) {
        do {
            let fileUploadRequest: FileUploadRequest = try httpRequest.queryParameters.decode(FileUploadRequest.self)
            
            guard let fileID = fileUploadRequest.fileID,
                  let transmissionID = fileUploadRequest.transmissionID,
                  let sessionID = fileUploadRequest.sessionID else {
                handleServerResponse(connection: connection, createErrorResponse(.badRequest))
                return
            }
            
            guard sessionID == server.session?.sessionId else {
                handleServerResponse(connection: connection, createErrorResponse(.unauthorized))
                return
            }
            
            guard let progressFile = server.session?.files[fileID],
                  progressFile.transmissionId == transmissionID,
                  let fileName = progressFile.file.fileName
            else {
                handleServerResponse(connection: connection, createErrorResponse(.forbidden))
                return
            }
            
            if httpRequest.bodyFullyReceived {
                sendSuccessResponse(connection: connection)
                progressFile.status = .finished
                
                checkAllFilesAreReceived()
            } else {
                let url = FileManager.tempDirectory(withFileName: fileName)
                progressFile.status = .transferring
                progressFile.url = url
                completion?(url)
            }
        } catch {
            
        }
    }
    
    func handleCloseConnectionRequest(connection: NWConnection, httpRequest: HTTPRequest) {
        do {
            let serverResponse = try generateCloseConnectionResponse(body: httpRequest.body)
            handleServerResponse(connection: connection, serverResponse)
        } catch let error as HTTPStatusCode {
            handleServerResponse(connection: connection, createErrorResponse(error))
        } catch {
            sendInternalServerError(connection: connection)
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
    private func handleServerResponse(connection: NWConnection, _ serverResponse: P2PServerResponse?) {
        guard let serverResponse = serverResponse else {
            sendInternalServerError(connection: connection)
            return
        }
        sendDataToConnection(connection: connection, serverResponse: serverResponse)
    }
    
    private func sendInternalServerError(connection: NWConnection) {
        let response = createErrorResponse(.internalServerError)
        sendDataToConnection(connection: connection, serverResponse: response)
    }
    
    private func sendDataToConnection(connection: NWConnection, serverResponse: P2PServerResponse) {
        guard let data = serverResponse.dataResponse else {
            debugLog("No data to send in server response")
            return
        }
        
        networkManager.sendData(connection: connection, data) { [weak self] error in
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
            stopServer()
        default:
            debugLog("Unhandled endpoint")
        }
    }
    
    private func handleErrors(httpRequest:HTTPRequest?, connection: NWConnection) {
        
        guard let httpRequest else {
            sendInternalServerError(connection: connection)
            return
        }
        
        switch PeerToPeerEndpoint(rawValue: httpRequest.endpoint ) {
        case .upload:
            do {
                let fileUploadRequest: FileUploadRequest = try httpRequest.queryParameters.decode(FileUploadRequest.self)
                
                guard let fileID = fileUploadRequest.fileID else {
                    sendInternalServerError(connection: connection)
                    return
                }
                let progressFile = server.session?.files[fileID]
                progressFile?.status = .failed
                sendInternalServerError(connection: connection)
            } catch {
                sendInternalServerError(connection: connection)
            }
            checkAllFilesAreReceived()
            
        default:
            sendInternalServerError(connection: connection)
        }
    }
    
    func checkAllFilesAreReceived()  {
        guard let files = server.session?.files else { return  }
        let filesAreNotfinishReceiving = files.filter({$0.value.status == .transferring || $0.value.status == .queue})
        if (filesAreNotfinishReceiving.isEmpty) {
            self.didSendProgress.send(completion: .finished)
        }
    }
    
    private func resetConnectionState() {
        currentHTTPRequest = nil
        server.reset()
    }
}

extension PeerToPeerServer: NetworkManagerDelegate {
    
    func networkManager(didFailWithListener error: Error?) {
        debugLog("Server error")
        self.didFailStartServerPublisher.send()
    }
    
    func networkManager(_ connection: NWConnection, didFailWith error: Error?, request: HTTPRequest?) {
        guard let request else { return  }
        handleErrors(httpRequest: request, connection: connection)
    }
    
    func networkManager(_ connection: NWConnection, didReceiveCompleteRequest request: HTTPRequest) {
        currentHTTPRequest = request
        processCompleteBody(connection: connection, httpRequest: request)
    }
    
    
    func networkManager(_ connection: NWConnection, verifyParametersForDataRequest request: HTTPRequest, completion: ((URL)-> Void)?) {
        currentHTTPRequest = request
        processCompleteBody(connection: connection, httpRequest: request, completion:completion)
    }
    
    func networkManager(_ connection: NWConnection, didReceive progress: Int, for request: HTTPRequest) {
        processProgress(connection: connection, progress: progress, httpRequest: request)
    }
    
    func networkManagerDidStartListening() {
        debugLog("Network manager started listening")
    }
    
    func networkManagerDidStopListening() {
        debugLog("Network manager did stop listening")
        self.didSendProgress.send(completion: .finished)
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
