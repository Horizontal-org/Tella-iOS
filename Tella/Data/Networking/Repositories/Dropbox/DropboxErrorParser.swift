//
//  DropboxErrorParser.swift
//  Tella
//
//  Created by gus valbuena on 10/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftyDropbox

class DropboxErrorParser {
    static func customDropboxErrorMessage(error: Error) -> String {
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

    private static func handleDropboxCallError<T>(_ error: CallError<T>) -> String {
        switch error {
        case .routeError(let boxedError, _, _, _):
            return parseDropboxRouteError(boxedError.unboxed)
        default:
            return LocalizableError.unexpectedResponse.localized
        }
    }

    private static func parseDropboxRouteError(_ unboxedError: Any) -> String {
        if let uploadError = unboxedError as? Files.UploadError {
            return handleUploadError(uploadError)
        } else if let uploadSessionFinishError = unboxedError as? Files.UploadSessionFinishError {
            return "Error while finishing Dropbox session"
        } else if unboxedError is Files.UploadSessionStartError {
            return "Error while starting Dropbox session"
        } else if let createFolderError = unboxedError as? Files.CreateFolderError {
            return handleCreateFolderError(createFolderError)
        } else {
            return LocalizableError.unexpectedResponse.localized
        }
    }

    private static func handleUploadError(_ error: Files.UploadError) -> String {
        switch error {
        case .path(let uploadWriteFailed):
            return handleUploadWriteFailed(uploadWriteFailed)
        default:
            return LocalizableError.unexpectedResponse.localized
        }
    }

    private static func handleCreateFolderError(_ error: Files.CreateFolderError) -> String {
        switch error {
        case .path(let writeError):
            return handleWriteError(writeError)
        }
    }

    private static func handleUploadWriteFailed(_ error: Files.UploadWriteFailed) -> String {
        return handleWriteError(error.reason)
    }

    private static func handleWriteError(_ error: Files.WriteError) -> String {
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
