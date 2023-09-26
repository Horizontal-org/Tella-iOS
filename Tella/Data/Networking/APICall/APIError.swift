//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum APIError: Swift.Error {
    case invalidURL
    case httpCode(HTTPCode)
    case unexpectedResponse
    case error(String)
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
        case .error(let message):
            return message
        case .noInternetConnection:
            return LocalizableSettings.settServerNoInternetConnection.localized
        }
    }
    private func customErrorMessage(errorCode : Int) -> String {
        let httpErrorCode = HTTPErrorCodes(rawValue: errorCode)
        switch httpErrorCode{
        case .unauthorized:
            return "Invalid username or password"
        case .forbidden:
            return "Account locked due to too many unsuccessful attempts."
        case .notFound, .badServer:
            return LocalizableSettings.settServerServerURLIncorrect.localized
        default:
            return "Custom Error"
        }
    }
}
