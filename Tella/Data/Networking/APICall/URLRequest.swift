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
            
            return NetworkSessionProvider().apiSession
        } catch {
            debugLog("Failed to create URLRequest: \(error)")
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

    func makeUploadRequestAndTask(
        endpoint: any APIRequest,
        fileURL: URL,
        session: URLSession
    ) throws -> (request: URLRequest, task: URLSessionUploadTask) {
        
        guard NetworkMonitor.shared.isConnected else {
            throw APIError.noInternetConnection
        }
        
        let request = try endpoint.urlRequest()
        request.curlRepresentation()
        
        let task = session.uploadTask(with: request, fromFile: fileURL)
        return (request, task)
    }
    
}

// MARK: - Helpers
extension Publisher where Output == ServerResponse {
    func requestJSON<Value>() -> APIResponse<Value> where Value: Decodable {
        return requestData()
            .tryMap({ (data, allHeaderFields) in
                if data.isEmpty, Value.self == EmptyResult.self {
                    return (EmptyResult() as! Value, allHeaderFields)
                }
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
