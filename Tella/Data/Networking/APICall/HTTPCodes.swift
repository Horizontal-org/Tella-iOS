//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation


typealias HTTPCode = Int
typealias HTTPCodes = Range<HTTPCode>

extension HTTPCodes {
    static let success = 200 ..< 300
}
enum HTTPErrorCodes: Int {
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case requestTimeout = 408
    case conflict = 409
    case tooManyRequests = 429
    case internalServerError = 500
    case unknown
}

enum NcHTTPErrorCodes: Int {
    case ncUnauthorizedError = 997
    case ncTooManyRequests = 429
    case ncNoInternetError = -1009
    case nextcloudFolderExists = 405
    case ncNoServerError = -1003
    case unauthorized = 401
    case nonExistentFolder = 409
}

enum GoggleDriveErrorCodes: Int {
    case scopesAlreadyGranted = -8
}
