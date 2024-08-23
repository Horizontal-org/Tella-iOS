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
            return LocalizableError.invalidUrl.localized
        case let .httpCode(code):
            return customErrorMessage(errorCode: code)
        case .unexpectedResponse:
            return LocalizableError.unexpectedResponse.localized
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
            return LocalizableError.unauthorized.localized
        case .forbidden:
            return LocalizableError.forbidden.localized
        case .notFound:
            return LocalizableSettings.settServerServerURLIncorrect.localized
        default:
            return LocalizableError.unexpectedResponse.localized
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
        
        return LocalizableError.unexpectedResponse.localized
    }
}
