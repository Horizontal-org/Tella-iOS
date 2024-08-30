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
    case errorOccured
    case nextcloudError(HTTPCode)
}

extension APIError: LocalizedError {

    var errorMessage: String {
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
        case let .nextcloudError(code):
            return customNcErrorMessage(errorCode: code)
        case .errorOccured :
            return LocalizableCommon.commonError.localized
        }
    }
    
    private func customNcErrorMessage(errorCode : Int) -> String {
        let httpErrorCode = NcHTTPErrorCodes(rawValue: errorCode)
        switch httpErrorCode{
        case .ncUnauthorized, .ncUnauthorizedError:
            return "The username or password is incorrect"
        case .ncNoInternetError:
            return "No Internet connection. Try again when you are connected to the Internet."
        case .nextcloudFolderExists:
            return "Folder already exist"
        default:
            return LocalizableError.unexpectedResponse.localized
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
            let errorMessage = nsError.localizedDescription
            
            switch nsError.domain {
            case GoogleAuthConstants.GTLRErrorObjectDomain, GoogleAuthConstants.HTTPStatus:
                return parseDriveErrorMessage(errorCode: nsError.code, fallbackMessage: errorMessage)
            default:
                return errorMessage
            }
        }
        
        return LocalizableError.unexpectedResponse.localized
    }
    
    private func parseDriveErrorMessage(errorCode: Int, fallbackMessage: String) -> String {
        let httpErrorCode = HTTPErrorCodes(rawValue: errorCode)
        switch httpErrorCode {
        case .unauthorized:
            return LocalizableError.gDriveUnauthorized.localized
        case .forbidden:
            return LocalizableError.gDriveForbidden.localized
        default:
            return fallbackMessage
        }
    }
}
