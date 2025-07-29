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

struct ConnectionContext {
    let connection: NWConnection
    var request: HTTPRequest
}

protocol NetworkManagerDelegate: AnyObject {
    func networkManager(didReceiveCompleteRequest context: ConnectionContext)
    func networkManager(verifyParametersFor context: ConnectionContext, completion: ((URL) -> Void)?)
    func networkManager(didReceive progress: Int, for context: ConnectionContext)
    func networkManagerDidStartListening()
    func networkManager(didFailWith error: Error?, context: ConnectionContext?)
    func networkManager(didFailWithListener error: Error?)
}

final class NetworkManager {
    // MARK: - Properties
    
    private var listener: NWListener?
    private var activeConnections: [ObjectIdentifier: ConnectionContext] = [:]
    weak var delegate: NetworkManagerDelegate?
    
    private let minIncompleteLength = 1
    private let maxLength = 1024 * 1024
    
    // MARK: - Lifecycle
    
    func startListening(port: Int, clientIdentity: SecIdentity) {
        stopListening()
        
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
        listener = nil
        
        for context in activeConnections.values {
            context.connection.cancel()
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
        
        let context = ConnectionContext(connection: connection, request: parser.request)
        activeConnections[connection.id] = context
        
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
            delegate?.networkManager(didFailWith: error, context: connectionContext(for: connection))
            cleanupConnection(connection, error: error)
        }
    }
    
    private func continueReceivingIfNeeded(on connection: NWConnection, parser: HTTPParser) {
        if parser.request.bodyFullyReceived {
            if let context = connectionContext(for: connection) {
                delegate?.networkManager(didReceiveCompleteRequest: context)
            }
        } else {
            receiveData(on: connection, using: parser)
        }
    }
    
    private func setupParserCallbacks(for parser: HTTPParser, connection: NWConnection) {
        parser.onReceiveBody = { [weak self] length in
            guard let self,
                  let context = self.updateContext(for: connection, with: parser.request) else { return }
            self.delegate?.networkManager(didReceive: length, for: context)
        }
        
        parser.onReceiveQueryParameters = { [weak self] in
            guard let self,
                  let context = self.updateContext(for: connection, with: parser.request) else { return }
            self.delegate?.networkManager(verifyParametersFor: context) { url in
                parser.fileURL = url
            }
        }
    }
    
    private func cleanupConnection(_ connection: NWConnection, error: Error?) {
        let context = connectionContext(for: connection)
        delegate?.networkManager(didFailWith: error, context: context)
        activeConnections.removeValue(forKey: connection.id)
    }
    
    private func connectionContext(for connection: NWConnection) -> ConnectionContext? {
        return activeConnections[connection.id]
    }
    
    private func updateContext(for connection: NWConnection,
                               with request: HTTPRequest) -> ConnectionContext? {
        guard var context = activeConnections[connection.id] else { return nil }
        context.request = request
        activeConnections[connection.id] = context
        return context
    }
    
}
