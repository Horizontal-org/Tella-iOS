//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

public protocol APIRequest {
    associatedtype Value
    var keyValues : [Key : Value?]? { get }
    var urlQueryParameters : [String : String?]? { get }
    
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var encoding: Encoding { get }
    var decoder: JSONDecoder { get }
    var headers: [String: String]? { get }
    var token: String? { get }
    var fileToUpload: FileInfo? { get }
    var url: URL? { get }
    var uploadsSession: URLSession? { get }
    var apiSession: URLSession? { get }
    var multipartBody: Data? { get }
    var multipartHeader: String? {get}
}

public extension APIRequest {
    
    typealias Key = String
    
    var keyValues: [Key : Value?]? { nil }
    var urlQueryParameters: [String : String?]? { nil }
    
    var encoding: Encoding { Encoding.json }
    var headers: [String: String]? {
        [HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
    }
    
    var token: String? {
        return nil
    }
    
    var decoder: JSONDecoder { JSONDecoder() }
    var fileToUpload: FileInfo? { nil }
    var url: URL? {
        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? path
        return URL(string: baseURL + encodedPath)
    }
    var uploadsSession: URLSession? { return nil }
    var apiSession: URLSession? { return nil }
    var multipartBody: Data? { nil }
    var multipartHeader: String? { nil }

}

extension APIRequest {
    
    func urlRequest() throws -> URLRequest {
        
        guard var url = url else {
            throw APIError.invalidURL
        }
        
        url = addURLQueryParameters(toURL: url)
        
        var request = URLRequest(url: url)
        
        if let headers {
            headers.keys.forEach { key in
                if let value = headers[key] {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
        }
        if let token {
            request.addValue(HTTPHeaderField.bearer.rawValue + token, forHTTPHeaderField: HTTPHeaderField.authorization.rawValue)
        }
        request.httpMethod = httpMethod.rawValue
        if encoding == .form {
            request.setValue(multipartHeader, forHTTPHeaderField: "Content-Type")
                
            request.httpBody = multipartBody
        } else {
            request.httpBody = try body()
        }

        request.timeoutInterval = TimeInterval(30)
        return request
    }
} 

extension APIRequest {
    
    func body(boundary: String? = nil) throws -> Data? {
        let keyValues = keyValues?.compactMapValues { $0 } ?? [:]
        
        let queryItemsDictionary = keyValues
            .reduce(into: [:]) { result, tuple in
                result[tuple.key.apiString] = tuple.value
            }
        if !queryItemsDictionary.isEmpty, encoding == .json {
            return try JSONSerialization.data(withJSONObject: queryItemsDictionary,
                                              options: .prettyPrinted
            )
        }
//        if let fileToUpload {
//            return getHttpBody(fieldInfo: fileToUpload)
//        }
        return nil
    }
    
    
    private func addURLQueryParameters(toURL url: URL) -> URL {
        guard let urlQueryParameters else { return url }
        
        if !urlQueryParameters.isEmpty  {
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
            var queryItems = [URLQueryItem]()
            for (key, value) in urlQueryParameters {
                if let value {
                    let item = URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                    queryItems.append(item)
                }
            }
            urlComponents.queryItems = queryItems
            
            guard let updatedURL = urlComponents.url else { return url }
            return updatedURL
        }
        
        return url
    }
    
//    func getHttpBody(fieldInfo:FileInfo) -> Data? {
//        let data = NSMutableData()
//        if let fieldInfoData = fieldInfo.data {
//            data.append(fieldInfoData)
//        }
//        return data as Data
//    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
