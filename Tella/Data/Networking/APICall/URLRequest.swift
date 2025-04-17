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
    private func fetchData(endpoint: any APIRequest) -> AnyPublisher<ServerResponse, Error> {
        guard NetworkMonitor.shared.isConnected else {
            return Fail(error: APIError.noInternetConnection)
                .eraseToAnyPublisher()
        }
        
        do {
            let request = try endpoint.urlRequest()
            request.curlRepresentation()
            
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = false
            
            var capturedServerHash: String?
            
            let delegate = AuthenticationChallengeDelegate(
                path:endpoint.path,
                trustedPublicKeyHash: endpoint.trustedPublicKeyHash,
                onReceiveServerPublicKeyHash: { hash in
                    capturedServerHash = hash
                }
            )
            
            return Future<ServerResponse, Error> { promise in
                let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
                let task = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        let nsError = error as NSError
                        switch (nsError.code) {
                        case (NSURLErrorCancelled):
                            promise(.failure(APIError.cancelAuthenticationChallenge(capturedServerHash)))
                        default:
                            promise(.failure(error))
                        }
                    } else if let data = data, let response = response {
                        let result = ServerResponse(data: data, response: response)
                        promise(.success(result))
                    } else {
                        promise(.failure(APIError.unexpectedResponse))
                    }
                }
                task.resume()
            }
            .eraseToAnyPublisher()
            
        } catch {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
    }
    
    func getAPIResponse<Value>(endpoint: any APIRequest) -> APIResponse<Value>
    where Value: Decodable {
        fetchData(endpoint: endpoint)
            .requestJSON()
            .eraseToAnyPublisher()
    }
    
    func getAPIResponseForBinaryData(endpoint: any APIRequest) -> APIResponse<Data> {
        fetchData(endpoint: endpoint)
            .requestData()
            .eraseToAnyPublisher()
    }
}
// MARK: - Helpers
extension Publisher where Output == ServerResponse {
    func requestJSON<Value>() -> APIResponse<Value> where Value: Decodable {
        let apiDataResponse = requestData()
        
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
    func requestData() -> APIDataResponse {
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
    var path: String
    var onReceiveServerPublicKeyHash: ((String) -> Void)?
    
    init(path: String, trustedPublicKeyHash: String? = nil, onReceiveServerPublicKeyHash: ((String) -> Void)? = nil) {
        self.path = path
        self.trustedPublicKeyHash = trustedPublicKeyHash
        self.onReceiveServerPublicKeyHash = onReceiveServerPublicKeyHash
    }
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        
        let host = challenge.protectionSpace.host
        
        guard host.isLocalNetworkHost(), let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        guard let publicKeyData = extractPublicKey(from: serverTrust) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverPublicKeyHash = publicKeyData.sha256()
        
        debugLog("serverPublicKeyHash \(serverPublicKeyHash)")
        debugLog("trustedPublicKeyHash \(trustedPublicKeyHash)")
        
        guard let trustedPublicKeyHash else {
            
            if self.path == PeerToPeerEndpoint.register.rawValue {
                onReceiveServerPublicKeyHash?(serverPublicKeyHash)
            }
            
            completionHandler(.cancelAuthenticationChallenge, nil)
            
            return
        }
        
        onReceiveServerPublicKeyHash?(serverPublicKeyHash)
        
        if trustedPublicKeyHash == serverPublicKeyHash {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            debugLog("Public key SHA-256 mismatch!")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
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


