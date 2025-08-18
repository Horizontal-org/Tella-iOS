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
    private let connections = ConnectionStore()
    private weak var delegate: NetworkManagerDelegate?
    
    private let minIncompleteLength = 1
    private let maxLength = 1024 * 1024
    
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
            listener.start(queue: .main)
        } catch {
            self.delegate?.networkManager(didFailWithListener: error)
        }
    }
    
    func stopListening() {
        if listener?.state != .cancelled {
            listener?.cancel()
        }
        Task {
            for conn in await connections.allConnections() {
                conn.cancel()
            }
            await connections.removeAll()
        }
    }
    
    func cleanConnections() {
        Task { await connections.removeAll() }
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
        
        sec_protocol_options_set_challenge_block(tlsOptions.securityProtocolOptions, { _, completion in
            completion(identity)
        }, .main)
        
        return NWParameters(tls: tlsOptions)
    }
    
    // MARK: - Listener Configuration
    
    private func configureListener(_ listener: NWListener) {
        listener.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            Task {
                switch state {
                case .ready:
                    debugLog("Listener ready")
                    let delegate = await self.delegate
                    delegate?.networkManagerDidStartListening()
                case .failed(let error):
                    debugLog("Listener failed")
                    let delegate = await self.delegate
                    delegate?.networkManager(didFailWithListener: error)
                    await self.stopListening()
                case .cancelled:
                    debugLog("Listener cancelled")
                default:
                    break
                }
            }
        }
        
        listener.newConnectionHandler = { [weak self] connection in
            Task { await self?.handleNewConnection(connection) }
        }
    }
    
    // MARK: - Connection Handling
    
    private func handleNewConnection(_ connection: NWConnection) {
        let parser = HTTPParser()
        configureParser(parser, for: connection)
        
        let context = ConnectionContext(connection: connection, request: parser.request)
        Task { await connections.set(context, for: connection.id) }
        
        connection.start(queue: .main)
        receiveData(on: connection, using: parser)
    }
    
    private func receiveData(on connection: NWConnection, using parser: HTTPParser) {
        connection.receive(minimumIncompleteLength: minIncompleteLength,
                           maximumLength: maxLength) { [weak self] data, _, _, error in
            guard let self else { return }
            Task {
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
            _ = await self.updateContext(for: connection, with: parser.request)
            if parser.parserIsPaused {
                return
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
        Task {
            if let ctx = await self.connectionContext(for: connection) {
                self.delegate?.networkManager(didReceiveCompleteRequest: ctx)
            }
        }
    }
    
    // MARK: - Parser Configuration
    
    private func configureParser(_ parser: HTTPParser, for connection: NWConnection) {
        parser.onReceiveBody = { [weak self] length in
            guard let self else { return }
            Task {
                if let context = await self.updateContext(for: connection, with: parser.request) {
                    let delegate = await self.delegate
                    delegate?.networkManager(didReceive: length, for: context)
                }
            }
        }
        
        parser.onReceiveQueryParameters = { [weak self] in
            guard let self else { return }
            Task {
                if let context = await self.updateContext(for: connection, with: parser.request),
                   let url = await self.delegate?.networkManager(verifyParametersFor: context) {
                    parser.fileURL = url
                    do {
                        try parser.resumeParsing()
                        _ = await self.updateContext(for: connection, with: parser.request)
                        await self.continueReceiving(connection: connection, parser: parser)
                    } catch {
                        await self.handleConnectionError(connection, error: error)
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func handleConnectionError(_ connection: NWConnection, error: Error?) async {
        let ctx = await self.connectionContext(for: connection)
        self.delegate?.networkManager(didFailWith: error, context: ctx)
        await self.connections.remove(for: connection.id)
        connection.cancel()
    }
    
    private func connectionContext(for connection: NWConnection) async -> ConnectionContext? {
        await connections.get(for: connection.id)
    }
    
    @discardableResult
    private func updateContext(for connection: NWConnection, with request: HTTPRequest) async -> ConnectionContext? {
        await connections.update(for: connection.id, with: request)
    }
}

actor ConnectionStore {
    
    private var storage: [ObjectIdentifier: ConnectionContext] = [:]
    
    func set(_ context: ConnectionContext, for id: ObjectIdentifier) {
        storage[id] = context
    }
    
    func get(for id: ObjectIdentifier) -> ConnectionContext? {
        storage[id]
    }
    
    @discardableResult
    func update(for id: ObjectIdentifier, with request: HTTPRequest) -> ConnectionContext? {
        guard var ctx = storage[id] else { return nil }
        ctx.request = request
        storage[id] = ctx
        return ctx
    }
    
    func remove(for id: ObjectIdentifier) {
        storage.removeValue(forKey: id)
    }
    
    func removeAll() {
        storage.removeAll()
    }
    
    func allConnections() -> [NWConnection] {
        storage.values.map { $0.connection }
    }
}
