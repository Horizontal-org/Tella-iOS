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
    func networkManager(_ connection: NWConnection, didReceiveCompleteRequest request: HTTPRequest)
    func networkManager(_ connection: NWConnection, verifyParametersForDataRequest request: HTTPRequest, completion: ((URL)-> Void)?)
    func networkManager(_ connection: NWConnection, didReceive progress: Int, for request: HTTPRequest)
    func networkManagerDidStartListening()
    func networkManagerDidStopListening()
    func networkManager(_ connection: NWConnection, didFailWith error: Error, request: HTTPRequest?)
    func networkManager(didFailWith error: Error )

}

final class NetworkManager {
    // MARK: - Properties
    private var listener: NWListener?
    weak var delegate: NetworkManagerDelegate?
    
    private let kMinimumIncompleteLength = 1
    private let kMaximumLength = 1024 * 1024
    
    // MARK: - Server Lifecycle
    func startListening(port: Int, clientIdentity: SecIdentity) {
        
        do {
            let parameters = try createNetworkParameters(clientIdentity: clientIdentity)
            self.listener = try NWListener(using: parameters, on: NWEndpoint.Port(integerLiteral: UInt16(port)))
            
            setupListenerHandlers()
            self.listener?.start(queue: .main)
        } catch {
            debugLog("Failed to start listener")
            delegate?.networkManager(didFailWith: error)
        }
    }
    
    func stopListening() {
        listener?.cancel()
    }
    
    func sendData(connection: NWConnection, _ data: Data, completion: ((NWError?) -> Void)? = nil) {
        connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                debugLog("Server send error")
            }
            completion?(error)
        })
    }
    
    // MARK: - Private Methods
    private func createNetworkParameters(clientIdentity: SecIdentity) throws -> NWParameters {
        let tlsOptions = NWProtocolTLS.Options()
        let parameters = NWParameters(tls: tlsOptions)
        
        guard let identity = sec_identity_create(clientIdentity) else {
            throw RuntimeError("Invalid Certificate")
        }
        sec_protocol_options_set_local_identity(tlsOptions.securityProtocolOptions, identity)
        
        sec_protocol_options_set_challenge_block(tlsOptions.securityProtocolOptions, { (_, completionHandler) in
            completionHandler(identity)
        }, .main)
        
        return parameters
    }
    
    private func setupListenerHandlers() {
        listener?.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .ready:
                debugLog("Listener is ready and waiting for connections")
                delegate?.networkManagerDidStartListening()
            case .failed(let error):
                debugLog("Listener failed")
                delegate?.networkManager(didFailWith: error)
                self.stopListening()
            case .cancelled:
                debugLog("Listener cancelled")
                delegate?.networkManagerDidStopListening()
            default:
                break
            }
        }
        
        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleNewConnection(connection)
        }
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        connection.start(queue: .main)
        let parser = HTTPParser()
        
        receive(connection,
                parser: parser)
    }
    
    private func receive(_ connection: NWConnection,
                         parser:HTTPParser) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: kMaximumLength) { [weak self] data, _, isComplete, error in
            
            guard let self = self else { return}
            
            if let error {
                self.handleReceiveError(connection:connection, error)
                return
            }
            guard let data else {
                debugLog("Failed to read HTTP data")
                return
            }

            processHTTPRequest(on: connection, data: data, parser: parser)
        }
        
    }
    
    private func handleReceiveError(connection:NWConnection , _ error: NWError) {
        debugLog("Connection error")
        delegate?.networkManager(connection, didFailWith: error, request:nil)
    }
    
    func processHTTPRequest(on connection: NWConnection,
                            data:Data,
                            parser:HTTPParser) {
        do {
            
            parser.onReceiveBody = { [weak self] length in
                debugLog(length)
                guard let self else { return }
                self.delegate?.networkManager(connection, didReceive: length, for: parser.request)
            }
            
            parser.onReceiveQueryParameters = {
                self.delegate?.networkManager(connection, verifyParametersForDataRequest: parser.request, completion: { url in
                    parser.fileURL = url
                })
            }
            
            try parser.parse(data: data)
            
            if parser.parserIsPaused {
                try parser.resumeParsing()
                check(on: connection, parser: parser)
            } else {
                check(on: connection, parser: parser)
            }

        } catch {
            debugLog("Failed to parse HTTP request")
            self.delegate?.networkManager(connection, didFailWith: error, request: parser.request)
        }
    }
    
    func check(on connection: NWConnection, parser:HTTPParser) {
        if parser.request.bodyFullyReceived {
            delegate?.networkManager(connection, didReceiveCompleteRequest: parser.request)
        } else {
            receive(connection,
                    parser: parser)
        }
    }
    
    func continueParsing() {
        
    }
}
