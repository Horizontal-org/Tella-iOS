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

enum P2PUploadResponse {
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
    
    func uploadFile(endpoint: any APIRequest) -> AnyPublisher<P2PUploadResponse, APIError> {
        do {
            
            let request = try endpoint.urlRequest()
            let configuration = URLSessionConfiguration.default
            request.curlRepresentation()
            
            let delegate = PeerToPeerURLSessionDelegate(
                path:endpoint.path,
                trustedCertificateHash: endpoint.trustedPublicKeyHash
            )
            guard let fileURL = endpoint.fileToUpload?.url else {   return Fail<P2PUploadResponse, APIError>(error: APIError.errorOccured)
                    .eraseToAnyPublisher()
            }
            
            let _ = fileURL.startAccessingSecurityScopedResource()
            defer { fileURL.stopAccessingSecurityScopedResource() }
            
            let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
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
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = false
            request.curlRepresentation()
            let delegate = PeerToPeerURLSessionDelegate(
                path:endpoint.path,
                trustedCertificateHash: endpoint.trustedPublicKeyHash
            )
            
            return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
                .dataTaskPublisher(for: request)
                .map({ ServerResponse(data: $0, response: $1)})
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchServerPublicKeyHash(endpoint: any APIRequest) -> AnyPublisher<String, Error> {
        do {
            let request = try endpoint.urlRequest()
            request.curlRepresentation()
            
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = false
            
            var capturedServerHash: String?
            
            let delegate = PeerToPeerURLSessionDelegate(
                path: endpoint.path,
                trustedCertificateHash: endpoint.trustedPublicKeyHash,
                onReceiveServerCertificateHash: { hash in
                    capturedServerHash = hash
                }
            )
            
            return Future<String, Error> { promise in
                let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
                
                let task = session.dataTask(with: request) { data, response, error in
                    
                    if let hash = capturedServerHash {
                        promise(.success(hash))
                    } else if let error {
                        debugLog("Network error while fetching hash: \(error)")
                        promise(.failure(error))
                    } else {
                        debugLog("Unexpected response: no error, no server hash")
                        promise(.failure(APIError.unexpectedResponse))
                    }
                }
                
                task.resume()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            
        } catch {
            debugLog("Failed to create URLRequest: \(error)")
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
    }
}
