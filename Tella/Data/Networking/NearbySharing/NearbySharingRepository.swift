//
//  NearbySharingRepository.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Combine
import UIKit

class NearbySharingRepository: NSObject, WebRepository {
    
    private var connectionInfo:ConnectionInfo?
    private var uploadTasks : [URLSessionTask] = []
    
    /// Tries each IP in order using `activeHost`, keeps the working host and stores `connectionInfo`, or restores the prior `activeHost` if all fail.
    func getHash(connectionInfo: ConnectionInfo) -> AnyPublisher<String, Error> {
        let hosts = NearbySharingIPAddressPreference.hostsToTry(from: connectionInfo.ipAddresses)
        guard !hosts.isEmpty else {
            return Fail(error: APIError.badServer).eraseToAnyPublisher()
        }
        let originalActiveHost = connectionInfo.activeHost
        return attemptSequentialHosts(
            connectionInfo: connectionInfo,
            hosts: hosts,
            index: 0,
            originalActiveHost: originalActiveHost
        ) { info in
            self.fetchServerPublicKeyHash(endpoint: API.ping(connectionInfo: info))
        }
    }
    
    /// Tries each IP in order using `activeHost`; keeps the working host and stores `connectionInfo`, or restores the prior `activeHost` if all fail.
    func register(connectionInfo: ConnectionInfo, registerRequest: RegisterRequest) -> AnyPublisher<RegisterResponse, APIError> {
        let hosts = NearbySharingIPAddressPreference.hostsToTry(from: connectionInfo.ipAddresses)
        guard !hosts.isEmpty else {
            return Fail(error: APIError.badServer).eraseToAnyPublisher()
        }
        let originalActiveHost = connectionInfo.activeHost
        return attemptSequentialHosts(
            connectionInfo: connectionInfo,
            hosts: hosts,
            index: 0,
            originalActiveHost: originalActiveHost
        ) { info in
            let apiResponse: APIResponse<RegisterResponse> = self.getLocalAPIResponse(
                endpoint: API.register(connectionInfo: info, registerRequest: registerRequest)
            )
            return apiResponse
                .compactMap { $0.response }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        .mapError { ($0 as? APIError) ?? APIError.unexpectedResponse }
        .eraseToAnyPublisher()
    }
    
    /// Retries the next `ip_address` on transport / reachability-style failures, not on application-level HTTP errors.
    private func shouldRetryWithNextIPAddress(_ error: Error) -> Bool {
        if let apiError = error as? APIError {
            switch apiError {
            case .badServer, .unexpectedResponse:
                return true
            default:
                return false
            }
        }
        let nsError = error as NSError
        return nsError.domain == NSURLErrorDomain
    }
    
    /// `baseURL` uses `ConnectionInfo.requestHost`, which prefers `activeHost`. Each attempt sets `activeHost` to the candidate IP; on total failure it is restored to `originalActiveHost`.
    private func attemptSequentialHosts<Output>(
        connectionInfo: ConnectionInfo,
        hosts: [String],
        index: Int,
        originalActiveHost: String?,
        publisherForPerHost: @escaping (ConnectionInfo) -> AnyPublisher<Output, Error>
    ) -> AnyPublisher<Output, Error> {
        guard index < hosts.count else {
            connectionInfo.activeHost = originalActiveHost
            return Fail(error: APIError.badServer).eraseToAnyPublisher()
        }
        let host = hosts[index]
        connectionInfo.activeHost = host
        return publisherForPerHost(connectionInfo)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.connectionInfo = connectionInfo
            })
            .catch { [weak self] error -> AnyPublisher<Output, Error> in
                guard let self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                if self.shouldRetryWithNextIPAddress(error), index + 1 < hosts.count {
                    return self.attemptSequentialHosts(
                        connectionInfo: connectionInfo,
                        hosts: hosts,
                        index: index + 1,
                        originalActiveHost: originalActiveHost,
                        publisherForPerHost: publisherForPerHost
                    )
                }
                connectionInfo.activeHost = originalActiveHost
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func prepareUpload(prepareUpload: PrepareUploadRequest) -> AnyPublisher<PrepareUploadResponse, APIError> {
        
        guard let connectionInfo else {return Fail(error: APIError.badServer)
            .eraseToAnyPublisher()}
        
        let apiResponse : APIResponse<PrepareUploadResponse> = getLocalAPIResponse(
            endpoint: API.prepareUpload(connectionInfo:connectionInfo,
                                        prepareUpload: prepareUpload))
        return apiResponse
            .compactMap{$0.response}
            .eraseToAnyPublisher()
    }
    
    func uploadFile(fileUploadRequest:FileUploadRequest, fileURL: URL) -> AnyPublisher<Int, APIError> {
        guard let connectionInfo else {
            return Fail(error: APIError.badServer)
                .eraseToAnyPublisher()
        }
        
        do {
            let apiResponse = uploadFile(
                endpoint: API.uploadFile(connectionInfo:connectionInfo,
                                         fileUploadRequest: fileUploadRequest,
                                         fileURL: fileURL))
            return apiResponse
                .compactMap { output in
                    switch output {
                    case .progress(let progress):
                        return progress
                    case .didCreateTask(let task):
                        self.uploadTasks.append(task)
                        return nil
                    default:
                        return nil
                    }
                }
                .eraseToAnyPublisher()
        }
    }
    @discardableResult
    func closeConnection(closeConnectionRequest: CloseConnectionRequest) -> AnyPublisher<BoolResponse, APIError> {
        guard let connectionInfo else {return Fail(error: APIError.badServer)
            .eraseToAnyPublisher()}
        
        let apiResponse : APIResponse<BoolResponse> = getLocalAPIResponse(endpoint: API.closeConnection(connectionInfo:connectionInfo,
                                                                                                        closeConnectionRequest: closeConnectionRequest))
        return apiResponse
            .compactMap{$0.response}
            .eraseToAnyPublisher()
    }
    
    func cancelUpload() {
        _ = uploadTasks.compactMap({$0.cancel()})
    }
}

extension NearbySharingRepository {
    
    enum API {
        case ping(connectionInfo:ConnectionInfo)
        case register(connectionInfo:ConnectionInfo, registerRequest:RegisterRequest)
        case prepareUpload(connectionInfo:ConnectionInfo, prepareUpload: PrepareUploadRequest)
        case uploadFile(connectionInfo:ConnectionInfo, fileUploadRequest:FileUploadRequest, fileURL:URL)
        case closeConnection(connectionInfo:ConnectionInfo, closeConnectionRequest: CloseConnectionRequest)
    }
}

extension NearbySharingRepository.API: APIRequest {
    
    typealias Value = Any
    
    var urlQueryParameters: [String: String?]? {
        switch self {
        case .uploadFile (_, let fileUploadRequest, _):
            return fileUploadRequest.uploadURLQueryParameters.compactMapValues { $0 }
        default:
            return nil
        }
    }
    
    var keyValues: [Key : Value?]? {
        
        switch self {
        case .ping:
            return nil
        case .register(_, let registerRequest):
            return registerRequest .dictionary
        case .prepareUpload(_, let prepareUpload):
            return prepareUpload.dictionary
        case .uploadFile:
            return nil
        case .closeConnection(_, let closeConnectionRequest):
            return closeConnectionRequest.dictionary
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .ping:
            return nil
        case .uploadFile:
            return [HTTPHeaderField.contentType.rawValue : ContentType.octetStream.rawValue]
        default:
            return [HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
        }
    }
    
    var baseURL: String {
        switch self {
        case .ping(let connectionInfos),
                .register(let connectionInfos, _),
                .prepareUpload(let connectionInfos, _),
                .uploadFile(let connectionInfos, _, _),
                .closeConnection(let connectionInfos, _):
            return "https://" + connectionInfos.requestHost + ":\(connectionInfos.port)"
        }
    }
    
    var path: String {
        switch self {
            
        case .ping:
            return NearbySharingEndpoint.ping.rawValue
            
        case .register:
            return NearbySharingEndpoint.register.rawValue
            
        case .prepareUpload:
            return  NearbySharingEndpoint.prepareUpload.rawValue
            
        case .uploadFile:
            return  NearbySharingEndpoint.upload.rawValue
            
        case .closeConnection:
            return NearbySharingEndpoint.closeConnection.rawValue
            
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .register, .prepareUpload, .closeConnection, .ping:
            return HTTPMethod.post
        case .uploadFile :
            return HTTPMethod.put
        }
    }
    
    var fileToUpload: FileInfo? {
        switch self {
        case .uploadFile (_, let file ,let fileURL):
            return FileInfo(withFileURL: fileURL, fileId: file.fileID)
        default:
            return nil
        }
    }
    
    var trustedPublicKeyHash: String? {
        switch self {
        case .register( let connectionInfo, _),
                .prepareUpload(let connectionInfo, _),
                .uploadFile(let connectionInfo, _, _),
                .closeConnection(let connectionInfo, _):
            return connectionInfo.certificateHash
            
        default:
            return nil
        }
    }
}

// MARK: - IPv4 subnet host selection
/// Only QR IPs whose three-octet prefix matches a local IPv4. Returns an empty list when no local IPs are found or none of the QR IPs match.
private enum NearbySharingIPAddressPreference {
    static func hostsToTry(from qrIPAddresses: [String]) -> [String] {
        let localSubnets = Set(
            UIDevice.current.ipAddresses()
                .compactMap { ipv4ThreeOctetPrefix(for: $0) }
        )
        return qrIPAddresses.filter { ip in
            guard let prefix = ipv4ThreeOctetPrefix(for: ip) else { return false }
            return localSubnets.contains(prefix)
        }
    }
    
    /// e.g. `192.168.88.2` → `192.168.88`. Non–dotted-quad strings return `nil` (IPv6 not supported here).
    private static func ipv4ThreeOctetPrefix(for address: String) -> String? {
        let parts = address.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 4 else { return nil }
        
        let octets = parts.compactMap { Int($0) }
        guard octets.count == 4,
              octets.allSatisfy({ (0...255).contains($0) }) else {
            return nil
        }
        return parts.dropLast().joined(separator: ".")
    }
}
