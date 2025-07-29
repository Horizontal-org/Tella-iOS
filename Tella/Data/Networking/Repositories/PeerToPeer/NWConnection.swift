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

// MARK: - ConnectionContext

struct ConnectionContext {
    let connection: NWConnection
    var request: HTTPRequest
}

// MARK: - NetworkManagerDelegate

protocol NetworkManagerDelegate: AnyObject {
    func networkManager(didReceiveCompleteRequest context: ConnectionContext)
    func networkManager(verifyParametersFor context: ConnectionContext, completion: ((URL) -> Void)?)
    func networkManager(didReceive progress: Int, for context: ConnectionContext)
    func networkManagerDidStartListening()
    func networkManager(didFailWith error: Error?, context: ConnectionContext?)
    func networkManager(didFailWithListener error: Error?)
}

// MARK: - NetworkManager

final class NetworkManager {
    
    // MARK: - Properties
    
    private var listener: NWListener?
    private var activeConnections: [ObjectIdentifier: ConnectionContext] = [:]
    private let queue: DispatchQueue
    
    weak var delegate: NetworkManagerDelegate?
    
    // MARK: - Constants
    
    private enum Constants {
        static let minIncompleteLength = 1
        static let maxLength = 1024 * 1024  // 1MB
        static let mainQueueLabel = "com.wearehorizontal.networkmanager.queue"
    }
    

    // MARK: - Initialization
    
    init(queue: DispatchQueue? = nil) {
        self.queue = queue ?? DispatchQueue(
            label: Constants.mainQueueLabel,
            qos: .userInitiated,
            attributes: .concurrent
        )
    }

    // MARK: - Public API
    
    func startListening(port: Int, clientIdentity: SecIdentity) {
        stopListening()
        
        do {
            let parameters = try createNetworkParameters(clientIdentity: clientIdentity)
            let portValue = NWEndpoint.Port(integerLiteral: UInt16(port))
            listener = try NWListener(using: parameters, on: portValue)
            
            configureListener()
            listener?.start(queue: .main)
        } catch {
            debugLog("Failed to start listener: \(error)")
            delegate?.networkManager(didFailWithListener: error)
        }
    }
    
    func stopListening() {
        if listener?.state != .cancelled {
            listener?.cancel()
        }
        for context in activeConnections.values {
            context.connection.cancel()
        }
    }
    
    func cleanConnections() {
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
    
    // MARK: - TLS Parameters
    
    private func createNetworkParameters(clientIdentity: SecIdentity) throws -> NWParameters {
        let tlsOptions = NWProtocolTLS.Options()
        guard let identity = sec_identity_create(clientIdentity) else {
            throw RuntimeError("Invalid certificate")
        }
        
        sec_protocol_options_set_local_identity(tlsOptions.securityProtocolOptions, identity)
        sec_protocol_options_set_challenge_block(tlsOptions.securityProtocolOptions, { _, completion in
            completion(identity)
        }, .main)
        
        return NWParameters(tls: tlsOptions)
    }
    
    // MARK: - Listener Configuration
    
    private func configureListener() {
        listener?.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                debugLog("Listener ready")
                delegate?.networkManagerDidStartListening()
            case .failed(let error):
                debugLog("Listener failed: \(error)")
                delegate?.networkManager(didFailWithListener: error)
                stopListening()
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
    
    // MARK: - Connection Handling
    
    private func handleNewConnection(_ connection: NWConnection) {
        connection.start(queue: queue)
        
        let parser = HTTPParser()
        configureParser(parser, for: connection)
        
        let context = ConnectionContext(connection: connection, request: parser.request)
        activeConnections[connection.id] = context
        
        receiveData(on: connection, using: parser)
    }
    
    private func receiveData(on connection: NWConnection, using parser: HTTPParser) {
        connection.receive(minimumIncompleteLength: Constants.minIncompleteLength, maximumLength: Constants.maxLength) { [weak self] data, _, _, error in
            guard let self else { return }
            
            if let error = error {
                self.handleConnectionError(connection, error: error)
                return
            }
            
            guard let data = data else {
                self.handleConnectionError(connection, error: nil)
                return
            }
            
            self.processIncomingData(data, on: connection, with: parser)
        }
    }
    
    private func processIncomingData(_ data: Data, on connection: NWConnection, with parser: HTTPParser) {
        do {
            try parser.parse(data: data)
            updateContext(for: connection, with: parser.request)
            
            if parser.parserIsPaused {
                try parser.resumeParsing()
            }
            
            continueReceiving(connection: connection, parser: parser)
        } catch {
            debugLog("Parsing error: \(error)")
            delegate?.networkManager(didFailWith: error, context: connectionContext(for: connection))
            handleConnectionError(connection, error: error)
        }
    }
    
    private func continueReceiving(connection: NWConnection, parser: HTTPParser) {
        guard parser.request.bodyFullyReceived else {
            receiveData(on: connection, using: parser)
            return
        }
        
        if let context = connectionContext(for: connection) {
            delegate?.networkManager(didReceiveCompleteRequest: context)
        }
    }
    
    // MARK: - Parser Configuration
    
    private func configureParser(_ parser: HTTPParser, for connection: NWConnection) {
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
    
    // MARK: - Helpers
    
    private func handleConnectionError(_ connection: NWConnection, error: Error?) {
        let context = connectionContext(for: connection)
        delegate?.networkManager(didFailWith: error, context: context)
        activeConnections.removeValue(forKey: connection.id)
        connection.cancel()
    }
    
    private func connectionContext(for connection: NWConnection) -> ConnectionContext? {
        activeConnections[connection.id]
    }
    
    @discardableResult
    private func updateContext(for connection: NWConnection, with request: HTTPRequest) -> ConnectionContext? {
        guard var context = activeConnections[connection.id] else { return nil }
        context.request = request
        activeConnections[connection.id] = context
        return context
    }
}
