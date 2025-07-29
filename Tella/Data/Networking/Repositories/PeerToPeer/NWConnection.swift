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

private struct ActiveConnection {
    let connection: NWConnection
    var request: HTTPRequest
}

protocol NetworkManagerDelegate: AnyObject {
    func networkManager(_ connection: NWConnection, didReceiveCompleteRequest request: HTTPRequest)
    func networkManager(_ connection: NWConnection, verifyParametersForDataRequest request: HTTPRequest, completion: ((URL) -> Void)?)
    func networkManager(_ connection: NWConnection, didReceive progress: Int, for request: HTTPRequest)
    func networkManagerDidStartListening()
    func networkManager(_ connection: NWConnection, didFailWith error: Error?, request: HTTPRequest?)
    func networkManager(didFailWithListener error: Error?)
}

final class NetworkManager {
    // MARK: - Properties
    
    private var listener: NWListener?
    private var activeConnections: [ObjectIdentifier: ActiveConnection] = [:]
    weak var delegate: NetworkManagerDelegate?
    
    private let minIncompleteLength = 1
    private let maxLength = 1024 * 1024
    
    // MARK: - Lifecycle
    
    func startListening(port: Int, clientIdentity: SecIdentity) {
        stopListening()  // Cancel existing listener if any
        
        do {
            let parameters = try createNetworkParameters(clientIdentity: clientIdentity)
            listener = try NWListener(using: parameters, on: NWEndpoint.Port(integerLiteral: UInt16(port)))
            setupListenerHandlers()
            listener?.start(queue: .main)
        } catch {
            debugLog("Failed to start listener")
            delegate?.networkManager(didFailWithListener: error)
        }
    }
    
    func stopListening() {
        if listener?.state != .cancelled {
            listener?.cancel()
        }
        
        for connection in activeConnections.values {
            connection.connection.cancel()
        }
    }
    
    func clean() {
        activeConnections.removeAll()
    }
    
    func sendData(to connection: NWConnection, data: Data, completion: ((NWError?) -> Void)? = nil) {
        connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                debugLog("Send error: \(error)")
            }
            completion?(error)
        })
    }
    
    // MARK: - Listener Setup
    
    private func createNetworkParameters(clientIdentity: SecIdentity) throws -> NWParameters {
        let tlsOptions = NWProtocolTLS.Options()
        guard let identity = sec_identity_create(clientIdentity) else {
            throw RuntimeError("Invalid certificate")
        }
        
        sec_protocol_options_set_local_identity(tlsOptions.securityProtocolOptions, identity)
        sec_protocol_options_set_challenge_block(tlsOptions.securityProtocolOptions, { _, completionHandler in
            completionHandler(identity)
        }, .main)
        
        return NWParameters(tls: tlsOptions)
    }
    
    private func setupListenerHandlers() {
        listener?.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                debugLog("Listener ready")
                self.delegate?.networkManagerDidStartListening()
            case .failed(let error):
                debugLog("Listener failed")
                self.delegate?.networkManager(didFailWithListener: error)
                self.stopListening()
            case .cancelled:
                debugLog("Listener cancelled")
            default:
                break
            }
        }
        
        listener?.newConnectionHandler = { [weak self] newConnection in
            self?.handleNewConnection(newConnection)
        }
    }
    
    // MARK: - Connection Handling
    
    private func handleNewConnection(_ connection: NWConnection) {
        connection.start(queue: .main)
        let parser = HTTPParser()
        setupParserCallbacks(for: parser, connection: connection)
        activeConnections[connection.id] = ActiveConnection(connection: connection, request: parser.request)
        receiveData(on: connection, using: parser)
    }
    
    private func receiveData(on connection: NWConnection, using parser: HTTPParser) {
        connection.receive(minimumIncompleteLength: minIncompleteLength, maximumLength: maxLength) { [weak self] data, _, _, error in
            guard let self else { return }
            
            if let error = error {
                self.cleanupConnection(connection, error: error)
                return
            }
            
            guard let data = data else {
                self.cleanupConnection(connection, error: nil)
                return
            }
            
            self.handleIncomingData(on: connection, data: data, parser: parser)
        }
    }
    
    private func handleIncomingData(on connection: NWConnection, data: Data, parser: HTTPParser) {
        do {
            try parser.parse(data: data)
            activeConnections[connection.id]?.request = parser.request
            
            if parser.parserIsPaused {
                try parser.resumeParsing()
            }
            
            continueReceivingIfNeeded(on: connection, parser: parser)
        } catch {
            debugLog("Parse error")
            delegate?.networkManager(connection, didFailWith: error, request: parser.request)
            cleanupConnection(connection, error: error)
        }
    }
    
    private func continueReceivingIfNeeded(on connection: NWConnection, parser: HTTPParser) {
        if parser.request.bodyFullyReceived {
            delegate?.networkManager(connection, didReceiveCompleteRequest: parser.request)
        } else {
            receiveData(on: connection, using: parser)
        }
    }
    
    private func setupParserCallbacks(for parser: HTTPParser, connection: NWConnection) {
        parser.onReceiveBody = { [weak self] length in
            self?.delegate?.networkManager(connection, didReceive: length, for: parser.request)
        }
        
        parser.onReceiveQueryParameters = { [weak self] in
            self?.delegate?.networkManager(connection, verifyParametersForDataRequest: parser.request) { url in
                parser.fileURL = url
            }
        }
    }
    
    private func cleanupConnection(_ connection: NWConnection, error: Error?) {
        let request = activeConnections[connection.id]?.request
        delegate?.networkManager(connection, didFailWith: error, request: request)
        activeConnections.removeValue(forKey: connection.id)
    }
}
