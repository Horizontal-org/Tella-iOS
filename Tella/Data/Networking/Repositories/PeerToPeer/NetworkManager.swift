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
    func networkManager(_ manager: NetworkManager, verifyParametersForDataRequest request: HTTPRequest, completion: ((URL)-> Void)?)
    func networkManager(_ manager: NetworkManager, didReceiveProgress request: HTTPRequest)
    
    func networkManagerDidStartListening(_ manager: NetworkManager)
    func networkManagerDidStopListening(_ manager: NetworkManager)
    func networkManager(_ manager: NetworkManager, didFailWith error: Error)
}

final class NetworkManager {
    // MARK: - Properties
    private var listener: NWListener?
    private var currentConnection: NWConnection?
    weak var delegate: NetworkManagerDelegate?
    
    private let kMinimumIncompleteLength = 1
    private let kMaximumLength = 64 * 1024
    
    // MARK: - Server Lifecycle
    func startListening(port: Int, clientIdentity: SecIdentity) {
        resetConnectionState()
        
        do {
            let parameters = try createNetworkParameters(clientIdentity: clientIdentity)
            self.listener = try NWListener(using: parameters, on: NWEndpoint.Port(integerLiteral: UInt16(port)))
            
            setupListenerHandlers()
            self.listener?.start(queue: .main)
        } catch {
            debugLog("Failed to start listener")
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
                delegate?.networkManagerDidStartListening(self)
            case .failed(let error):
                debugLog("Listener failed")
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
        let parser = HTTPParser()
        
        receive(connection,
                maximumLength: kMaximumLength,
                parser: parser)
    }
    
    private func receive(_ connection: NWConnection,
                         maximumLength:Int?,
                         parser:HTTPParser) {
        var maximumLength = (maximumLength ?? kMaximumLength)
        maximumLength = maximumLength == 0 ? 1 : maximumLength
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: maximumLength) { [weak self] data, _, isComplete, error in
            
            guard let self = self else { return}
            
            if let error {
                self.handleReceiveError(error)
                return
            }
            
            guard let data else {
                debugLog("Failed to read HTTP data")
                return
            }
            
            if isComplete {
            }
            
            processHTTPRequest(on: connection, data: data, parser: parser)
        }
        
    }
    
    private func handleReceiveError(_ error: NWError) {
        debugLog("Connection error")
        delegate?.networkManager(self, didFailWith: error)
    }
    
    func processHTTPRequest(on connection: NWConnection,
                            data:Data,
                            parser:HTTPParser) {
        do {
            
            parser.onReceiveBody = {
                
            }
            
            try parser.parse(data: data)
            
            if parser.parserIsPaused {
                
                self.delegate?.networkManager(self, verifyParametersForDataRequest: parser.request, completion: { url in
                    do {
                        parser.fileURL = url
                        try parser.resumeParsing()
                        self.check(on: connection, parser: parser)
                    } catch {
                        debugLog("Failed to parse HTTP request")
                        self.delegate?.networkManager(self, didFailWith: error)
                    }
                })
                
            } else {
                check(on: connection, parser: parser)
            }
        } catch {
            debugLog("Failed to parse HTTP request")
            self.delegate?.networkManager(self, didFailWith: error)
        }
    }
    
    func check(on connection: NWConnection, parser:HTTPParser)  {
        if parser.request.bodyFullyReceived {
            delegate?.networkManager(self, didReceiveCompleteRequest: parser.request)
        } else {
            receive(connection,
                    maximumLength: parser.request.headers.contentLength,
                    parser: parser)
        }
        
    }
    
    
    func continueParsing() {
        
    }
    
    private func resetConnectionState() {
        currentConnection = nil
    }
}
