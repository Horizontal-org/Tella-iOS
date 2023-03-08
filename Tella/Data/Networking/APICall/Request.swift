//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

public enum ContentType: String {
    case json = "application/json"
    case data = "multipart/form-data"
}

public enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    case authorization = "Authorization"
    case bearer = "Bearer "
}

public enum Encoding {
    case json
    case form
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case patch = "PATCH"
    case put = "PUT"
    case head = "HEAD"

}
