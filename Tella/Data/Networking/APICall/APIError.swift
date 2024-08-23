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
    case badServer
    case noToken
    case driveApiError(Error)
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
        case .badServer:
            return LocalizableSettings.settServerServerURLIncorrect.localized
        case .noToken:
            return LocalizableSettings.settServerNoTokenPresent.localized
        case .driveApiError(let error):
            return customDriveErrorMessage(error: error)
        }
    }
    private func customErrorMessage(errorCode : Int) -> String {
        let httpErrorCode = HTTPErrorCodes(rawValue: errorCode)
        switch httpErrorCode{
        case .unauthorized:
            return "Invalid username or password"
        case .forbidden:
            return "Account locked due to too many unsuccessful attempts."
        case .notFound:
            return LocalizableSettings.settServerServerURLIncorrect.localized
        default:
            return "Unexpected response from the server"
        }
    }
    
    private func customDriveErrorMessage(error: Error) -> String {
        if let nsError = error as NSError? {
            switch nsError.domain {
            case GoogleAuthConstants.GTLRErrorObjectDomain:
                let errorCode = nsError.code
                let errorMessage = nsError.localizedDescription
                            
                return customErrorMessage(errorCode: errorCode)
            case GoogleAuthConstants.HTTPStatus:
                return customErrorMessage(errorCode: nsError.code)
            default:
                if let errorString = nsError.userInfo["error"] as? String {
                    return errorString
                }
            }
        }
        
        return "Unexpected response from the server"
    }
}
