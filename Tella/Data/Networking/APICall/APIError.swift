//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum APIError: Swift.Error {
    case invalidURL
    case httpCode(HTTPCode)
    case unexpectedResponse
    case noInternetConnection
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case let .httpCode(code):
            return customErrorMessage(errorCode: code)
        case .unexpectedResponse:
            return "Unexpected response from the server"
        case .noInternetConnection:
            return LocalizableSettings.settServerNoInternetConnection.localized
        }
    }
    
    func customErrorMessage(errorCode : Int) -> String {
        switch errorCode {
        default:
            return "Custom Error"
        }
    }
}
