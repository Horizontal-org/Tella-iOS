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
    
    func startManualPing(endpoint: any APIRequest) throws -> ManualPingSession {
        let request = try endpoint.urlRequest()
        request.curlRepresentation()
        
        let hashSubject = PassthroughSubject<String, Error>()
        let pingSubject = PassthroughSubject<Bool, Error>()
        var didEmitHash = false
        
        let delegate = NearbySharingURLSessionDelegate(
            path: endpoint.path,
            trustedCertificateHash: endpoint.trustedPublicKeyHash,
            clientTLSIdentity: endpoint.clientCertificateIdentity,
            onReceiveServerCertificateHash: { hash in
                guard !didEmitHash else { return }
                didEmitHash = true
                hashSubject.send(hash)
                hashSubject.send(completion: .finished)
            }
        )
        
        let session = NetworkSessionProvider().makeNearbySharingSession(delegate: delegate)
        let task = session.dataTask(with: request) { data, response, error in
            if let error {
                debugLog("Network error while waiting for ping response: \(error)")
                if !didEmitHash {
                    hashSubject.send(completion: .failure(error))
                }
                pingSubject.send(completion: .failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                if !didEmitHash {
                    hashSubject.send(completion: .failure(APIError.unexpectedResponse))
                }
                pingSubject.send(completion: .failure(APIError.unexpectedResponse))
                return
            }
            
            let statusCode = httpResponse.statusCode
            guard HTTPCodes.success.contains(statusCode) else {
                debugLog("Error code: \(statusCode)")
                let apiError = APIError.httpCode(statusCode)
                if !didEmitHash {
                    hashSubject.send(completion: .failure(apiError))
                }
                pingSubject.send(completion: .failure(apiError))
                return
            }
            
            let senderShowHash = (try? JSONDecoder().decode(PingResponse.self, from: data ?? Data()))?
                .senderShowHash ?? false
            pingSubject.send(senderShowHash)
            pingSubject.send(completion: .finished)
        }
        task.resume()
        
        return ManualPingSession(
            receiverCertificateHash: hashSubject
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher(),
            senderShowHash: pingSubject
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher(),
            task: task
        )
    }
}
