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
