//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftyDropbox

enum APIError: Swift.Error {
    case invalidURL
    case httpCode(HTTPCode)
    case unexpectedResponse
    case noInternetConnection
    case badServer
    case noToken
    case driveApiError(Error)
    case dropboxApiError(Error)
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
            return LocalizableError.commonError.localized
        case .dropboxApiError(let error):
            return customDropboxErrorMessage(error: error)
        }
    }
    
    private func customNcErrorMessage(errorCode : Int) -> String {
        let httpErrorCode = NcHTTPErrorCodes(rawValue: errorCode)
        switch httpErrorCode{
        case .ncUnauthorizedError:
            return LocalizableError.ncInvalidCredentials.localized
        case .ncNoInternetError:
            return LocalizableError.noInternet.localized
        case .nextcloudFolderExists:
            return LocalizableError.ncFolderExist.localized
        case .ncTooManyRequests:
            return LocalizableError.ncTooManyRequests.localized
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
    
    private func customDropboxErrorMessage(error: Error) -> String {
        if let uploadError = error as? CallError<Files.UploadError> {
            switch uploadError {
            case .routeError(let boxedError, _, _, _):
                let uploadError = boxedError.unboxed
                switch uploadError {
                case .path(let uploadWriteFailed):
                    switch uploadWriteFailed.reason {
                    case .insufficientSpace:
                        return "Not enough space in your Dropbox account."
                    default:
                        return "Upload failed due to a path error."
                    }
                default:
                    return "Upload failed due to an unknown error."
                }
            case .authError(let authError, _, _, _):
                return "Authentication error: \(authError)"
            case .clientError(let clientError):
                return "Client error: \(clientError.localizedDescription)"
            default:
                return "An unexpected error occurred."
            }
        } else {
            debugLog(error)
            return error.localizedDescription
        }
    }
}
