//
//  DropboxError.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 22/10/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftyDropbox


enum DropboxError {
    case noInternetConnection
    case noToken
    case incorrectOffset(offset: UInt64)
    case sessionNotFound
    case conflict
    case insufficientSpace
    case noWritePermission
    case disallowedName
    case malformedPath
    case teamFolder
    case tooManyWriteOperations
    case other
    case dropboxStartSession
    case unknown
}

typealias UploadSessionStart = UploadRequest<Files.UploadSessionStartResultSerializer, Files.UploadSessionStartErrorSerializer>
typealias UploadSessionAppend = UploadRequest<VoidSerializer, Files.UploadSessionAppendErrorSerializer>
typealias UploadSessionFinish = UploadRequest<Files.FileMetadataSerializer, Files.UploadSessionFinishErrorSerializer>
typealias UploadError = CallError<Files.UploadError>
typealias CreateFolderError = CallError<Files.CreateFolderError>
typealias UploadSessionStartError = CallError<Files.UploadSessionStartError>
typealias UploadSessionFinishError = CallError<Files.UploadSessionFinishError>
typealias UploadSessionAppendError = CallError<Files.UploadSessionAppendError>

extension Error {
    
    func getError(error: Error) -> DropboxError {
        
        switch self {
            
        case let error as UploadError:
            
            if case .authError = error {
                return .noToken
            }
            
            let res = handleDropboxCallError(error)
            if case .path(let writeError) = res {
                return getWriteError(writeError.reason)
            }
            
        case let error as UploadSessionFinishError:
            
            if case .authError = error {
                return .noToken
            }
            
            let res = handleDropboxCallError(error)
            if case .path(let writeError) = res {
                return getWriteError(writeError)
            }
            
        case let error as UploadSessionAppendError:
            
            if case .authError = error {
                return .noToken
            }
            
            let res = handleDropboxCallError(error)
            
            switch res {
            case .incorrectOffset(let offset):
                return .incorrectOffset(offset: offset.correctOffset)
            case .notFound:
                return .sessionNotFound
                
            default:
                return .unknown
            }
            
        case _ as UploadSessionStartError:
            return .dropboxStartSession
            
        case let error as CreateFolderError:
            
            if case .authError = error {
                return .noToken
            }
            
            let res = handleDropboxCallError(error)
            if case .path(let writeError) = res {
                return getWriteError(writeError)
            }
            
        default:
            return .unknown
        }
        return .unknown
    }
    
    private func handleDropboxCallError<T>(_ error: CallError<T>) -> T? {
        
        guard case .routeError(let boxedError, _, _, _) = error
        else { return nil }
        
        return  boxedError.unboxed
    }
    
    private func getWriteError(_ error: Files.WriteError) -> DropboxError {
        switch error {
        case .conflict:
            return .conflict
        case .insufficientSpace:
            return .insufficientSpace
        case .noWritePermission:
            return .noWritePermission
        case .disallowedName:
            return .disallowedName
        case .malformedPath:
            return .malformedPath
        case .teamFolder:
            return .teamFolder
        case .tooManyWriteOperations:
            return .tooManyWriteOperations
        case .other:
            return .other
        default:
            return .unknown
        }
    }
}
