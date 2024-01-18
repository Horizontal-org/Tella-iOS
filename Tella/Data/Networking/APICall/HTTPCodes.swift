//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
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
    case methodNotAllowed = 405
    case requestTimeout = 408
    case need2FA = 409
    case internalServerError = 500
    case unknown
}

