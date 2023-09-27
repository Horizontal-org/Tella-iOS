//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

typealias APIResponse<Value> = AnyPublisher<(Value,[AnyHashable:Any]?), APIError>
typealias APIDataResponse = AnyPublisher<(Data,[AnyHashable:Any]?), APIError>

protocol WebRepository {}

extension WebRepository {
    func getAPIResponse<Value>(endpoint: any APIRequest) -> APIResponse<Value>
    where Value: Decodable {
        do {
            guard (NetworkMonitor.shared.isConnected) else {
                return Fail(error: APIError.noInternetConnection)
                    .eraseToAnyPublisher()
            }
            let request = try endpoint.urlRequest()
            request.curlRepresentation()
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = false
            
            return URLSession(configuration: configuration)
                .dataTaskPublisher(for: request)
                .requestJSON()
        } catch _ {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
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
            } else  {
                let error = error as NSError
                if error.domain == NSURLErrorDomain {
                    return APIError.badServer
                } else {
                    return APIError.httpCode(error._code)
                }

            }
        }
        .eraseToAnyPublisher()
    }
}
