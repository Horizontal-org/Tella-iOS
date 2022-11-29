//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum API {
    enum Request {}
    enum Response {}
}

public protocol APIRequest  {
    
    associatedtype ResultType
    associatedtype Key : KeyType
    
    static var startURLPath: String? { get }
    static var httpMethod: Request.HTTPMethod { get }
    static var encoding: Request.Encoding { get }
    static var decoder: JSONDecoder { get }
    
    static func fetched(data: Data) throws -> ResultType
    
    
}

public extension APIRequest where ResultType: Decodable {
    
    static var httpMethod: Request.HTTPMethod { .get }
    static var encoding: Request.Encoding { httpMethod.defaultEncoding }
    static var headers: [String: String]? { nil }
    
    static var startURLPath: String? {
        return nil
    }
    
    static var decoder: JSONDecoder { .init(dateDecodingStrategy: .iso8601) }
    
    static func fetched(data: Data) throws -> ResultType {
        try decoder.decode(ResultType.self, from: data)
    }
}

extension APIRequest {
    
    static func request(headers: [String : String]? = nil,
                        keyValues: [Key: Value?]? = nil,
                        baseURL:String?) throws -> URLRequest {
        
        let keyValues = keyValues?.compactMapValues { $0 } ?? [:]
        
        let queryItemsDictionary = keyValues
            .reduce(into: [:]) { result, tuple in
                result[tuple.key.apiString] = tuple.value
            }
        let urlPathComponents =  [startURLPath].compactMap { $0 }
        
        return try URLRequest(
            baseURL: baseURL,
            urlPathComponents: urlPathComponents,
            queryItemsDictionary: queryItemsDictionary,
            headers: headers,
            httpMethod: httpMethod,
            encoding: encoding
        )
    }
}

public extension JSONDecoder {
    convenience init(dateDecodingStrategy: DateDecodingStrategy) {
        self.init()
    }
}
