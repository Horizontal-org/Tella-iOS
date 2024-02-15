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
    private func fetchData(endpoint: any APIRequest) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        do {
            guard NetworkMonitor.shared.isConnected else {
                return Fail(error: APIError.noInternetConnection)
                    .eraseToAnyPublisher()
            }
            let request = try endpoint.urlRequest()
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = false

            return URLSession(configuration: configuration)
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
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw APIError.unexpectedResponse
                }
                guard httpResponse.statusCode == 200 || httpResponse.statusCode == 206 else {
                    throw APIError.httpCode(httpResponse.statusCode)
                }
                return (output.data, httpResponse.allHeaderFields)
            }
            .mapError { error in
                (error as? APIError) ?? APIError.unexpectedResponse
            }
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
