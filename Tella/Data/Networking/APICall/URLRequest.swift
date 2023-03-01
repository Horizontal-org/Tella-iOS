//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

protocol WebRepository {}

extension WebRepository {
    func call<Value>(endpoint: any APIRequest) -> AnyPublisher<Value, APIError>
    where Value: Decodable {
        do {
            let request = try endpoint.urlRequest()
            request.curlRepresentation()
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = true
            
            return URLSession(configuration: configuration)
                .dataTaskPublisher(for: request)
                .requestJSON()
        } catch _ {
            return Fail<Value, APIError>(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - Helpers

extension Publisher where Output == URLSession.DataTaskPublisher.Output {
func requestJSON<Value>() -> AnyPublisher<Value, APIError> where Value: Decodable {
    return requestData()
        .decode(type: Value.self, decoder: JSONDecoder())
        .mapError{ _ in APIError.unexpectedResponse }
        .eraseToAnyPublisher()
}
}

extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    func requestData() -> AnyPublisher<Data, APIError> {
        return tryMap {
            guard let code = ($0.1 as? HTTPURLResponse)?.statusCode else {
                throw APIError.unexpectedResponse
            }
            guard HTTPCodes.success.contains(code) else {
                debugLog("Error code: \(code)")
                throw APIError.httpCode(code)
            }
            
            if let size = ($0.1 as? HTTPURLResponse)?.allHeaderFields.filter({($0.key as? String) == "size"}),
               !size.isEmpty   {
                
                if let jsonString = JSONStringEncoder().encode(size as! [String:Any]) {
                    return jsonString
                }
            }
            let dataString = String(decoding:  $0.0 , as: UTF8.self)
            debugLog("Result:\(dataString)")
            return $0.0
        }
        .mapError{ _ in APIError.unexpectedResponse }
        .eraseToAnyPublisher()
    }
}
