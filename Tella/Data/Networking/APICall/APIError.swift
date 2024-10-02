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
    
    
    // dropbox
    private func customDropboxErrorMessage(error: Error) -> String {
        var actualError = error
        if let apiError = error as? APIError, case let .dropboxApiError(underlyingError) = apiError {
            actualError = underlyingError
        }

        if let uploadError = actualError as? CallError<Files.UploadError> {
            return handleDropboxCallError(uploadError)
        } else if let uploadSessionFinishError = actualError as? CallError<Files.UploadSessionFinishError> {
            return handleDropboxCallError(uploadSessionFinishError)
        } else if let uploadSessionStartError = actualError as? CallError<Files.UploadSessionStartError> {
            return handleDropboxCallError(uploadSessionStartError)
        } else if let createFolderError = actualError as? CallError<Files.CreateFolderError> {
            return handleDropboxCallError(createFolderError)
        } else {
            return LocalizableError.unexpectedResponse.localized
        }
    }

    private func handleDropboxCallError<T>(_ error: CallError<T>) -> String {
        switch error {
        case .routeError(let boxedError, _, _, _):
            return parseDropboxRouteError(boxedError.unboxed)
        case .authError(let authError, _, _, _):
            return "Authentication error: \(authError)"
        case .clientError(let clientError):
            return "Client error: \(clientError.localizedDescription)"
        default:
            return LocalizableError.unexpectedResponse.localized
        }
    }

    private func parseDropboxRouteError(_ unboxedError: Any) -> String {
        if let uploadError = unboxedError as? Files.UploadError {
            return handleUploadError(uploadError)
        } else if let uploadSessionFinishError = unboxedError as? Files.UploadSessionFinishError {
            return handleUploadSessionFinishError(uploadSessionFinishError)
        } else if let uploadSessionStartError = unboxedError as? Files.UploadSessionStartError {
            return "Error starting session"
        } else if let createFolderError = unboxedError as? Files.CreateFolderError {
            return handleCreateFolderError(createFolderError)
        } else {
            return "An unexpected Dropbox error occurred."
        }
    }

    private func handleUploadError(_ error: Files.UploadError) -> String {
        switch error {
        case .path(let uploadWriteFailed):
            return handleUploadWriteFailed(uploadWriteFailed)
        case .other:
            return "An unknown upload error occurred."
        default:
            return LocalizableError.unexpectedResponse.localized
        }
    }

    private func handleUploadSessionFinishError(_ error: Files.UploadSessionFinishError) -> String {
        switch error {
        case .path(let uploadWriteFailed):
            return handleWriteError(uploadWriteFailed)
        case .lookupFailed(let lookupError):
            return "Upload session lookup failed: \(lookupError)"
        case .other:
            return "An unknown upload session finish error occurred."
        default:
            return LocalizableError.unexpectedResponse.localized
        }
    }

    private func handleCreateFolderError(_ error: Files.CreateFolderError) -> String {
        switch error {
        case .path(let writeError):
            return handleWriteError(writeError)
        }
    }
    
    private func handleUploadWriteFailed(_ error: Files.UploadWriteFailed) -> String {
        return handleWriteError(error.reason)
    }

    
    private func handleWriteError(_ error: Files.WriteError) -> String {
        switch error {
        case .conflict:
            return "A file or folder with the same name already exists."
        case .insufficientSpace:
            return "Not enough space in your Dropbox. Please free up some space and try again."
        case .noWritePermission:
            return "You do not have permission to write to this location."
        case .disallowedName:
            return "The file or folder name contains invalid characters."
        case .malformedPath(let path):
            return "The specified path is malformed: \(path ?? "Unknown path")."
        case .teamFolder:
            return "Cannot modify team folders."
        case .tooManyWriteOperations:
            return "Too many write operations. Please try again later."
        case .other:
            return "An unknown path error occurred."
        default:
            return LocalizableError.unexpectedResponse.localized
        }
    }
    
    
}
