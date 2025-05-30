//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

typealias APIResponse<Value> = AnyPublisher<(APIResult<Value>), APIError>
typealias APIDataResponse = AnyPublisher<(APIResult<Data>), APIError>

class APIResult<Value> {
    let response: Value
    let headers: [AnyHashable: Any]?
    
    init(response: Value, headers: [AnyHashable : Any]?) {
        self.response = response
        self.headers = headers
    }
}

struct ServerResponse {
    let data: Data
    let response: URLResponse
}

protocol WebRepository {}

extension WebRepository {
    
    func getAPIResponse<Value>(endpoint: any APIRequest) -> APIResponse<Value>
    where Value: Decodable {
        performRemoteRequest(endpoint: endpoint)
            .decodeJSONResponse()
            .eraseToAnyPublisher()
    }
    
    func getAPIResponseForBinaryData(endpoint: any APIRequest) -> APIResponse<Data> {
        performRemoteRequest(endpoint: endpoint)
            .extractData()
            .eraseToAnyPublisher()
    }
    
    func getLocalAPIResponse<Value>(endpoint: any APIRequest) -> APIResponse<Value>
    where Value: Decodable {
        performLocalRequest(endpoint: endpoint)
            .decodeJSONResponse()
            .eraseToAnyPublisher()
    }
    
    
    private func performRemoteRequest(endpoint: any APIRequest) -> AnyPublisher<ServerResponse, Error> {
        do {
            guard NetworkMonitor.shared.isConnected else {
                return Fail(error: APIError.noInternetConnection)
                    .eraseToAnyPublisher()
            }
            let request = try endpoint.urlRequest()
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = false
            request.curlRepresentation()
            
            return URLSession(configuration: configuration)
                .dataTaskPublisher(for: request)
                .map({ ServerResponse(data: $0, response: $1)})
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
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
            let delegate = AuthenticationChallengeDelegate(
                path:endpoint.path,
                trustedPublicKeyHash: endpoint.trustedPublicKeyHash
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
            
            let delegate = AuthenticationChallengeDelegate(
                path: endpoint.path,
                trustedPublicKeyHash: endpoint.trustedPublicKeyHash,
                onReceiveServerPublicKeyHash: { hash in
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
            .receive(on: DispatchQueue.main) // optional: push result to main thread
            .eraseToAnyPublisher()
            
        } catch {
            debugLog("Failed to create URLRequest: \(error)")
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - Helpers
extension Publisher where Output == ServerResponse {
    func decodeJSONResponse<Value>() -> APIResponse<Value> where Value: Decodable {
        let apiDataResponse = extractData()
        
        return apiDataResponse
            .tryMap({ response in
                let decodedData : Value = try response.response.decoded()
                return APIResult(response: decodedData, headers: response.headers)
            })
            .mapError{
                if let error = $0 as? APIError {
                    return error
                } else {
                    return APIError.unexpectedResponse
                }
                
            }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == ServerResponse {
    func extractData() -> APIDataResponse {
        return tryMap {
            guard let code = ($0.response as? HTTPURLResponse)?.statusCode else {
                throw APIError.unexpectedResponse
            }
            
            guard HTTPCodes.success.contains(code) else {
                debugLog("Error code: \(code)")
                throw APIError.httpCode(code)
            }
            return APIResult(response: $0.data , headers:($0.response as? HTTPURLResponse)?.allHeaderFields)
        }
        .mapError{ error in
            if let error = error as? APIError {
                return error
            }
            
            let nsError = error as NSError
            
            switch (nsError.code, nsError.domain) {
            case (NSURLErrorNotConnectedToInternet, _):
                return APIError.noInternetConnection
            case(_, NSURLErrorDomain):
                return APIError.badServer
            default:
                return APIError.httpCode(nsError.code)
            }
        }
        .eraseToAnyPublisher()
    }
}

class AuthenticationChallengeDelegate: NSObject, URLSessionDelegate {
    
    var trustedPublicKeyHash : String?
    var path: String?
    var onReceiveServerPublicKeyHash: ((String) -> Void)?
    
    init(path: String?, trustedPublicKeyHash: String? = nil, onReceiveServerPublicKeyHash: ((String) -> Void)? = nil) {
        self.path = path
        self.trustedPublicKeyHash = trustedPublicKeyHash
        self.onReceiveServerPublicKeyHash = onReceiveServerPublicKeyHash
    }
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let protectionSpace = challenge.protectionSpace
        let host = protectionSpace.host
        
        guard host.isLocalNetworkHost() else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        guard let serverTrust = protectionSpace.serverTrust else {
            debugLog("Missing serverTrust for host: \(host)")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        guard let publicKeyData = extractPublicKey(from: serverTrust) else {
            debugLog("Failed to extract public key from serverTrust for host: \(host)")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverPublicKeyHash = publicKeyData.sha256()
        debugLog("Received server public key hash: \(serverPublicKeyHash)")
        debugLog("Expected trusted public key hash: \(trustedPublicKeyHash ?? "nil")")
        
        // No trusted public key hash: potentially first connection
        guard let trustedHash = trustedPublicKeyHash else {
            if path == nil {
                onReceiveServerPublicKeyHash?(serverPublicKeyHash)
                completionHandler(.useCredential, nil)
            } else {
                debugLog("No trusted hash and path is non-nil; canceling authentication.")
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
            return
        }
        
        // Compare hashes
        guard trustedHash == serverPublicKeyHash else {
            debugLog("Public key hash mismatch! Expected \(trustedHash), got \(serverPublicKeyHash)")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }
    
    func extractPublicKey(from trust: SecTrust) -> Data? {
        guard let certificate = SecTrustGetCertificateAtIndex(trust, 0),
              let publicKey = SecCertificateCopyKey(certificate),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            return nil
        }
        return publicKeyData
    }
}


