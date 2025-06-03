//
//  NetworkManager.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 21/5/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Network
import Foundation

protocol NetworkManagerDelegate: AnyObject {
    func networkManager(_ manager: NetworkManager, didReceiveCompleteRequest request: HTTPRequest)
    func networkManagerDidStartListening(_ manager: NetworkManager)
    func networkManagerDidStopListening(_ manager: NetworkManager)
    func networkManager(_ manager: NetworkManager, didFailWith error: Error)
    func networkManagerDidEncounterTLSError(_ manager: NetworkManager)
}

final class NetworkManager {
    // MARK: - Properties
    private var listener: NWListener?
    private var currentConnection: NWConnection?
    weak var delegate: NetworkManagerDelegate?
    
    
    // MARK: - Server Lifecycle
    func startListening(port: Int, pin: String, clientIdentity: SecIdentity) {
        resetConnectionState()
        
        do {
            let parameters = try createNetworkParameters(clientIdentity: clientIdentity)
            self.listener = try NWListener(using: parameters, on: NWEndpoint.Port(integerLiteral: UInt16(port)))
            
            setupListenerHandlers()
            self.listener?.start(queue: .main)
        } catch {
            debugLog("Failed to start listener: \(error.localizedDescription)")
            delegate?.networkManager(self, didFailWith: error)
        }
    }
    
    func stopListening() {
        listener?.cancel()
        currentConnection?.cancel()
        resetConnectionState()
    }
    
    func sendData(_ data: Data, completion: ((NWError?) -> Void)? = nil) {
        guard let connection = currentConnection else {
            debugLog("No active connection to send data")
            return
        }
        
        connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                debugLog("Server send error: \(error)")
            }
            completion?(error)
        })
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
                delegate?.networkManagerDidStartListening(self)
            case .failed(let error):
                debugLog("Listener failed: \(error.localizedDescription)")
                delegate?.networkManager(self, didFailWith: error)
                self.stopListening()
            case .cancelled:
                debugLog("Listener cancelled")
                delegate?.networkManagerDidStopListening(self)
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
            
            guard let self = self else { return}
            
            if let error {
                self.handleReceiveError(error)
                return
            }
            
            guard let data else {
                debugLog("Failed to read HTTP data")
                return
            }
            
            do {
                let parser = HTTPParser()
                let request = try parser.parse(data: data)
                self.processHTTPRequest(request, on: connection,parser: parser)
            } catch {
                debugLog("Failed to parse HTTP request: \(error)")
                self.delegate?.networkManager(self, didFailWith: error)
            }
        }
    }
    
    private func handleReceiveError(_ error: NWError) {
        debugLog("Connection error: \(error.localizedDescription)")
        delegate?.networkManager(self, didFailWith: error)
        
        if case .tls(let tlsErrorCode) = error {
            debugLog("TLS Error: \(tlsErrorCode)")
            delegate?.networkManagerDidEncounterTLSError(self)
        }
    }
    
    private func processHTTPRequest(_ httpRequest: HTTPRequest, on connection: NWConnection, parser:HTTPParser) {
        guard let expectedLength = httpRequest.headers.contentLength else {
            debugLog("Content-Length header missing")
            return
        }
        
        let body = httpRequest.body
        
        if body.utf8.count < expectedLength {
            debugLog("Body incomplete, waiting for more (\(body.count)/\(expectedLength))")
            receiveRemainingBody(on: connection, httpRequest: httpRequest,
                                 expectedLength: expectedLength,
                                 remaining: expectedLength - body.count,
                                 parser: parser)
        } else {
            debugLog("Full JSON Body: \(body)")
            delegate?.networkManager(self, didReceiveCompleteRequest: httpRequest)
        }
    }
    
    private func receiveRemainingBody(on connection: NWConnection, httpRequest: HTTPRequest,
                                      expectedLength: Int,
                                      remaining: Int,
                                      parser:HTTPParser) {
        connection.receive(minimumIncompleteLength: remaining, maximumLength: remaining) { [weak self] data, _, _, error in
            guard let self = self else { return}
            if let error = error {
                debugLog("Error receiving remaining body: \(error)")
                self.delegate?.networkManager(self, didFailWith: error)
                return
            }
            
            guard let data else {
                debugLog("Failed to decode remaining data")
                return
            }
            
            do {
                let request = try parser.parse(data: data)
                
                let fullBody = httpRequest.body + request.body
                debugLog("Full JSON Body after completion: \(fullBody)")
                
                var completedRequest = httpRequest
                completedRequest.body = fullBody
                self.delegate?.networkManager(self, didReceiveCompleteRequest: completedRequest)
                
            } catch {
                debugLog("Failed to parse HTTP request: \(error)")
                self.delegate?.networkManager(self, didFailWith: error)
            }
        }
    }
    
    private func resetConnectionState() {
        currentConnection = nil
    }
}
