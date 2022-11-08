//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

public enum Request {}

public extension Request {

    enum ContentType: String {
        case json = "application/json"
        case data = "multipart/form-data"
    }

    enum HTTPHeaderField: String {
        case contentType = "Content-Type"
        case authorization = "Authorization"
    }

    enum Encoding {
        case json
        case form
    }
    
    enum HTTPMethod: String {
        
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case patch = "PATCH"
        case put = "PUT"
        
        var defaultEncoding: Encoding {
            return .json
        }
    }
}

