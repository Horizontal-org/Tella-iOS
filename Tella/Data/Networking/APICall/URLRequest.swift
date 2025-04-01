//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

typealias APIResponse<Value> = AnyPublisher<(Value,[AnyHashable:Any]?), APIError>
typealias APIDataResponse = AnyPublisher<(Data,[AnyHashable:Any]?), APIError>

protocol WebRepository {}

extension WebRepository {
    private func fetchData(endpoint: any APIRequest) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        do {
            guard NetworkMonitor.shared.isConnected else {
                return Fail(error: APIError.noInternetConnection)
                    .eraseToAnyPublisher()
            }
            let request = try endpoint.urlRequest()
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = false
            request.curlRepresentation()
            return URLSession(configuration: configuration,delegate: AuthenticationChallengeDelegate(trustedPublicKeyHash:endpoint.trustedPublicKeyHash), delegateQueue: nil)
                .dataTaskPublisher(for: request)
                .mapError { $0 as Error }
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
extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    func requestJSON<Value>() -> APIResponse<Value> where Value: Decodable {
        return requestData()
            .tryMap({ (data, allHeaderFields) in
                let decodedData : Value = try data.decoded()
                return (decodedData, allHeaderFields)
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

extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    func requestData() -> APIDataResponse {
        return tryMap {
            guard let code = ($0.1 as? HTTPURLResponse)?.statusCode else {
                throw APIError.unexpectedResponse
            }
            
            guard HTTPCodes.success.contains(code) else {
                debugLog("Error code: \(code)")
                throw APIError.httpCode(code)
            }
            return ($0.0, ($0.1 as? HTTPURLResponse)?.allHeaderFields)
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
    
    init(trustedPublicKeyHash: String? = nil) {
        self.trustedPublicKeyHash = trustedPublicKeyHash
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
        
        if let trustedHash = trustedPublicKeyHash, trustedHash == serverPublicKeyHash {
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
