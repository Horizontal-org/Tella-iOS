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
    func networkManager(verifyParametersFor context: ConnectionContext) async -> URL?
    func networkManager(didReceive progress: Int, for context: ConnectionContext)
    func networkManagerDidStartListening()
    func networkManager(didFailWith error: Error?, context: ConnectionContext?)
    func networkManager(didFailWithListener error: Error?)
}

actor NetworkManager {
    
    // MARK: - Properties
    
    private var listener: NWListener?
    private var activeConnections: [ObjectIdentifier: ConnectionContext] = [:]
    
    private weak var delegate: NetworkManagerDelegate?
    
    private let minIncompleteLength = 1
    private let maxLength = 1024 * 1024
    
    // A background queue for Network.framework runloops.
    private let networkQueue = DispatchQueue(label: "NearbySharing.NetworkListener")
    
    // MARK: - Delegate
    
    func setDelegate(_ delegate: NetworkManagerDelegate?) {
        self.delegate = delegate
    }
    
    // MARK: - Public API
    
    func startListening(port: Int, clientIdentity: SecIdentity) {
        if let l = listener, l.state != .cancelled {
            return
        }
        
        do {
            let parameters = try createNetworkParameters(clientIdentity: clientIdentity)
            let portValue = NWEndpoint.Port(integerLiteral: UInt16(port))
            let listener = try NWListener(using: parameters, on: portValue)
            
            self.listener = listener
            configureListener(listener)
            listener.start(queue: networkQueue)
        } catch {
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
    
    func sendData(to connection: NWConnection, data: Data) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            connection.send(content: data, completion: .contentProcessed { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            })
        }
    }
    
    // MARK: - TLS Parameters
    
    private func createNetworkParameters(clientIdentity: SecIdentity) throws -> NWParameters {
        let tlsOptions = NWProtocolTLS.Options()
        guard let identity = sec_identity_create(clientIdentity) else {
            throw RuntimeError("Invalid certificate")
        }
        sec_protocol_options_set_local_identity(tlsOptions.securityProtocolOptions, identity)
        
        // Use our network queue for the challenge block
        sec_protocol_options_set_challenge_block(tlsOptions.securityProtocolOptions, { _, completion in
            completion(identity)
        }, networkQueue)
        
        return NWParameters(tls: tlsOptions)
    }
    
    // MARK: - Listener Configuration
    
    private func configureListener(_ listener: NWListener) {
        listener.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            Task { [weak self] in
                guard let self else { return }
                switch state {
                case .ready:
                    debugLog("Listener ready")
                    await self.delegate?.networkManagerDidStartListening()
                case .failed(let error):
                    debugLog("Listener failed")
                    await self.delegate?.networkManager(didFailWithListener: error)
                    await self.stopListening()
                case .cancelled:
                    debugLog("Listener cancelled")
                default:
                    break
                }
            }
        }
        listener.newConnectionHandler = { [weak self] connection in
            guard let self else { return }
            Task { [weak self] in
                await self?.handleNewConnection(connection)
            }
        }
    }
    
    // MARK: - Connection Handling
    
    private func handleNewConnection(_ connection: NWConnection) {
        let parser = HTTPParser()
        configureParser(parser, for: connection)
        
        let context = ConnectionContext(connection: connection, request: parser.request)
        activeConnections[connection.id] = context
        
        // Start the connection on a dedicated queue
        connection.start(queue: DispatchQueue(label: "Nearby.Connection.\(connection.idHash)"))
        receiveData(on: connection, using: parser)
    }
    
    private func receiveData(on connection: NWConnection, using parser: HTTPParser) {
        connection.receive(minimumIncompleteLength: minIncompleteLength, maximumLength: maxLength) { [weak self] data, _, _, error in
            guard let self else { return }
            Task { [weak self] in
                guard let self else { return }
                if let error = error {
                    await self.handleConnectionError(connection, error: error)
                    return
                }
                guard let data = data else {
                    await self.handleConnectionError(connection, error: nil)
                    return
                }
                await self.processIncomingData(data, on: connection, with: parser)
            }
        }
    }
    
    private func processIncomingData(_ data: Data, on connection: NWConnection, with parser: HTTPParser) async {
        do {
            try parser.parse(data: data)
            _ = updateContext(for: connection, with: parser.request)
            
            if parser.parserIsPaused {
                try parser.resumeParsing()
            }
            
            continueReceiving(connection: connection, parser: parser)
        } catch {
            debugLog("Parsing error")
            await self.handleConnectionError(connection, error: error)
        }
    }
    
    private func continueReceiving(connection: NWConnection, parser: HTTPParser) {
        guard parser.request.bodyFullyReceived else {
            receiveData(on: connection, using: parser)
            return
        }
        if let ctx = connectionContext(for: connection) {
            Task { [weak self] in
                guard let self else { return }
                await self.delegate?.networkManager(didReceiveCompleteRequest: ctx)
            }
        }
    }
    
    // MARK: - Parser Configuration
    
    private func configureParser(_ parser: HTTPParser, for connection: NWConnection) {
        parser.onReceiveBody = { [weak self] length in
            guard let self else { return }
            Task { [weak self] in
                guard let self else { return }
                if let context = await self.updateContext(for: connection, with: parser.request) {
                    await self.delegate?.networkManager(didReceive: length, for: context)
                }
            }
        }
        
        parser.onReceiveQueryParameters = { [weak self] in
            guard let self else { return }
            Task { [weak self] in
                guard let self else { return }
                if let context = await self.updateContext(for: connection, with: parser.request),
                   let url = await self.delegate?.networkManager(verifyParametersFor: context) {
                    parser.fileURL = url
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func handleConnectionError(_ connection: NWConnection, error: Error?) async {
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

