//
//  LocalURLRequest.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/6/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Combine
import Security

enum NearbySharingUploadResponse {
    case initial
    case didCreateTask(task: URLSessionTask)
    case progress(progress: Int)
}

extension WebRepository {
    
    func getLocalAPIResponse<Value>(endpoint: any APIRequest) -> APIResponse<Value>
    where Value: Decodable {
        performLocalRequest(endpoint: endpoint)
            .decodeJSONResponse()
            .eraseToAnyPublisher()
    }
    
    func uploadFile(endpoint: any APIRequest) -> AnyPublisher<NearbySharingUploadResponse, APIError> {
        do {
            
            let request = try endpoint.urlRequest()
            request.curlRepresentation()
            
            let delegate = NearbySharingURLSessionDelegate(
                path: endpoint.path,
                trustedCertificateHash: endpoint.trustedPublicKeyHash,
                clientTLSIdentity: endpoint.clientCertificateIdentity
            )
            guard let fileURL = endpoint.fileToUpload?.url else {   return Fail<NearbySharingUploadResponse, APIError>(error: APIError.errorOccured)
                    .eraseToAnyPublisher()
            }
            
            let _ = fileURL.startAccessingSecurityScopedResource()
            defer { fileURL.stopAccessingSecurityScopedResource() }
            
            let session = NetworkSessionProvider().makeNearbySharingSession(delegate: delegate)
            let task = session.uploadTask(with: request, fromFile: fileURL)
            
            task.resume()
            
            return delegate.response.eraseToAnyPublisher()
        } catch {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
    }
    
    private func performLocalRequest(endpoint: any APIRequest) -> AnyPublisher<ServerResponse, Error> {
        do {
            
            let request = try endpoint.urlRequest()
            request.curlRepresentation()
            let delegate = NearbySharingURLSessionDelegate(
                path: endpoint.path,
                trustedCertificateHash: endpoint.trustedPublicKeyHash,
                clientTLSIdentity: endpoint.clientCertificateIdentity
            )
            
            return NetworkSessionProvider().makeNearbySharingSession(delegate: delegate)
                .dataTaskPublisher(for: request)
                .map({ ServerResponse(data: $0, response: $1)})
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchServerPublicKeyHash(endpoint: any APIRequest) -> AnyPublisher<NearbySharingPingResult, Error> {
        do {
            let request = try endpoint.urlRequest()
            request.curlRepresentation()

            var capturedServerHash: String?
            
            let delegate = NearbySharingURLSessionDelegate(
                path: endpoint.path,
                trustedCertificateHash: endpoint.trustedPublicKeyHash,
                clientTLSIdentity: endpoint.clientCertificateIdentity,
                onReceiveServerCertificateHash: { hash in
                    capturedServerHash = hash
                }
            )
            
            return NetworkSessionProvider().makeNearbySharingSession(delegate: delegate)
                .dataTaskPublisher(for: request)
                .map { ServerResponse(data: $0, response: $1) }
                .tryMap { serverResponse in
                    guard let code = (serverResponse.response as? HTTPURLResponse)?.statusCode else {
                        throw APIError.unexpectedResponse
                    }
                    guard HTTPCodes.success.contains(code) else {
                        debugLog("Error code: \(code)")
                        throw APIError.httpCode(code)
                    }
                    guard let hash = capturedServerHash else {
                        debugLog("Unexpected response: no server hash")
                        throw APIError.unexpectedResponse
                    }
                    let senderShowHash = (try? JSONDecoder().decode(PingResponse.self, from: serverResponse.data))?
                        .senderShowHash ?? false
                    return NearbySharingPingResult(
                        certificateHash: hash,
                        senderShowHash: senderShowHash
                    )
                }
                .mapError { $0 as Error }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            debugLog("Failed to create URLRequest: \(error)")
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
    }
}
