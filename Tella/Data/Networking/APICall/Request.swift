//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

public enum ContentType: String {
    case json = "application/json"
    case data = "multipart/form-data"
}

public enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    case contentLength = "Content-Length"
    case authorization = "Authorization"
    case bearer = "Bearer "
    case cookie = "Cookie"
    case xRequestedWith = "X-Requested-With"
    case tellaPlatform = "X-Tella-Platform"
    case ByPassCaptchaHeader = "Bypass-Captcha"
    case connection = "Connection"
}

public enum XRequestedWithValue: String {
    case xmlHttp = "XMLHttpRequest"
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

