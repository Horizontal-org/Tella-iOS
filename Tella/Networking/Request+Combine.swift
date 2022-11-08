//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

import Combine

public extension APIRequest {
    
    static func publisher(headers: [String: String]? = nil,
                          keyValues: [Key:  Value?]? = nil,
                          serverURL: String?) -> AnyPublisher<ResultType, TellaError> {
        do {
            return try publisher(request: request(headers: headers,
                                                  keyValues: keyValues,
                                                  baseURL: serverURL) )
        } catch {
            return Fail<ResultType, TellaError>(error: error as! TellaError)
                .eraseToAnyPublisher()
        }
    }
}
var subscribers = Set<AnyCancellable>()

private extension APIRequest {
    
    static func dataPublisher(request: URLRequest) -> AnyPublisher<Data, TellaError> {
        
        URLSession.shared.dataTaskPublisher(for: request)
            .eraseToAnyPublisher()
            .tryMap { (data: Data, response: URLResponse) in
                
                debugLog("Response : \(response)")
                debugLog("Response data : \( String(describing: String(data: data, encoding: .utf8)))")
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode >= 400 {
                    throw TellaError.init(httpResponse: httpResponse)
                }
                
                return data
            }
        
            .mapError { error -> TellaError in
                return error as? TellaError ?? TellaError.init(error: error)
            }
        
            .eraseToAnyPublisher()
    }
    
    static func publisher(request: URLRequest) -> AnyPublisher<ResultType, TellaError> {
        dataPublisher(request: request)
            .tryMap(fetched)
            .mapError { error -> TellaError in
                return error as? TellaError ?? TellaError.init(error: error)
            }
            .eraseToAnyPublisher()
    }
    
}
