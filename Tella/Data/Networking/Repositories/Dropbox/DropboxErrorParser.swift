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
            return handleUploadSessionFinishError(uploadSessionFinishError)
        } else if unboxedError is Files.UploadSessionStartError {
            return LocalizableError.dropboxStartSession.localized
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
    
    private static func handleUploadSessionFinishError(_ error: Files.UploadSessionFinishError) -> String {
        switch error {
        case .path(let uploadWriteFailed):
            return handleWriteError(uploadWriteFailed)
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
        default:
            return LocalizableError.unexpectedResponse.localized
        }
    }
}
