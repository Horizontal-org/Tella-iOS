//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

extension URLRequest {
    
    init(url: URL,
         queryItemsDictionary: [String: Any]? = nil,
         headers: [String: String]? = nil,
         httpMethod: Request.HTTPMethod,
         encoding: Request.Encoding) throws {
        
        let queryURL: URL
        
        if let queryItemsDictionary = queryItemsDictionary, encoding == .form {
            queryURL = try url.addingQuery(
                dictionary: queryItemsDictionary
                    .mapValues { String(describing: $0) }
            )
        } else {
            queryURL = url
        }
        
        self.init(url: queryURL)
        self.timeoutInterval = TimeInterval(15)
        self.httpMethod = httpMethod.rawValue
        
        self.addValue(Request.ContentType.json.rawValue, forHTTPHeaderField: Request.HTTPHeaderField.contentType.rawValue)
        
        headers?.keys.forEach { key in
            self.addValue(headers![key]!, forHTTPHeaderField: key)
        }
        if let queryItemsDictionary = queryItemsDictionary,
           !queryItemsDictionary.isEmpty,
           encoding == .json
        {
            self.httpBody = try JSONSerialization.data(withJSONObject: queryItemsDictionary,
                                                       options: .prettyPrinted
            )
        }
    }
    
    init(baseURL: String?,
         urlPathComponents: [String],
         queryItemsDictionary: [String: Any]? = nil,
         headers: [String: String]? = nil,
         httpMethod: Request.HTTPMethod,
         encoding: Request.Encoding) throws {
        
        if let url = URL(string: baseURL ?? "") {
            
            try self.init(url: url.appendingPathComponents(urlPathComponents),
                          queryItemsDictionary: queryItemsDictionary,
                          headers: headers,
                          httpMethod: httpMethod,
                          encoding: encoding
            )
        } else {
            throw TellaError()
        }
    }
}

extension URL {
    
    func addingQuery(dictionary: [String: String]) throws -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        else { throw TellaError() }
        if !dictionary.isEmpty {
            components.queryItemsDictionary = dictionary
        }
        guard let queryURL = components.url
        else { throw TellaError() }
        return queryURL
    }
    
    func appendingPathComponents(_ pathComponents: [String]) -> URL {
        guard let lastPathComponent = pathComponents.last
        else { return self }
        var url = self
        pathComponents.dropLast().forEach { url.appendPathComponent($0, isDirectory: true) }
        url.appendPathComponent(lastPathComponent)
        return url
    }
}

public extension URLComponents {
    
    var queryItemsDictionary: [String : String]? {
        get {
            return queryItems?.reduce([String : String]()) { (dictionary, queryItem) in
                var newDictionary = dictionary
                newDictionary[queryItem.name] = queryItem.value
                return newDictionary
            }
        }
        set {
            queryItems = newValue?.enumerated().reduce([URLQueryItem]()) { (queryItems, tuple) in
                var newQueryItems = queryItems
                newQueryItems.append(URLQueryItem(name: tuple.element.key, value: tuple.element.value))
                return newQueryItems
            }
        }
    }
    
}
