//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
    case tooManyRequests
    case driveApiError(Error)
    case dropboxApiError(DropboxError)
    case errorOccured
    case nextcloudError(HTTPCode)
    case cancelAuthenticationChallenge(String?)
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
        case .tooManyRequests:
            return LocalizableError.ncTooManyRequests.localized
        case .cancelAuthenticationChallenge:
            return "Cancelled"

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
    
    private func customDropboxErrorMessage(error: DropboxError) -> String {
        switch error {
        case .conflict:
            return LocalizableError.dropboxFileConflict.localized
        case .insufficientSpace:
            return LocalizableError.dropboxInsufficientSpace.localized
        case .noWritePermission:
            return LocalizableError.dropboxNoWritePermission.localized
        case .disallowedName:
            return LocalizableError.dropboxDisallowedName.localized
        case .malformedPath:
            return LocalizableError.dropboxMalformedPath.localized
        case .teamFolder:
            return LocalizableError.dropboxTeamFolder.localized
        case .tooManyWriteOperations:
            return LocalizableError.dropboxTooManyWriteOperations.localized
        case .other:
            return LocalizableError.dropboxOther.localized
        case .noInternetConnection:
            return LocalizableSettings.settServerNoInternetConnection.localized
        default:
            return LocalizableError.unexpectedResponse.localized
        }
    }
    
    static func convertNextcloudError(errorCode: HTTPCode) -> APIError {
        if [NcHTTPErrorCodes.unauthorized.rawValue,
            NcHTTPErrorCodes.ncUnauthorizedError.rawValue].contains(errorCode) {
            return .noToken
        } else if NcHTTPErrorCodes.ncTooManyRequests.rawValue == errorCode {
            return .tooManyRequests
        } else {
            return .nextcloudError(errorCode)
        }
    }

    static func convertDropboxError(_ error: DropboxError) -> APIError {
      
        switch error {
        case .noToken:
            return .noToken
         default:
            return .dropboxApiError(error)
        }
    }
}

