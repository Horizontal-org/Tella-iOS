//
//  NearbySharingServerHandler.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/8/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Network
import Foundation

protocol PingHandler {
    func handlePingRequest(on connection: NWConnection)
}

protocol RegisterHandler {
    func handleRegisterRequest(on connection: NWConnection, request: HTTPRequest)
    func acceptRegisterRequest(connection: NWConnection, httpRequest: HTTPRequest) async
    func respondToRegistrationRequest(accept: Bool)
}

protocol PrepareUploadHandler {
    func handlePrepareUploadRequest(on connection: NWConnection, request: HTTPRequest)
    func respondToFileOffer(accept: Bool)
}

protocol UploadHandler {
    func handleFileUploadRequest(on connection: NWConnection, request: HTTPRequest) async -> URL?
    func handleReceivedCompleteRequest(on connection: NWConnection, request: HTTPRequest) 
    func processProgress(connection: NWConnection, bytesReceived: Int, for request: HTTPRequest)
}

protocol CloseConnectionHandler {
    func handleCloseConnectionRequest(on connection: NWConnection, request: HTTPRequest)
}
