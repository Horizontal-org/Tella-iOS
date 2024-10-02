//
//  DropboxRepository.swift
//  Tella
//
//  Created by gus valbuena on 9/3/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
import SwiftyDropbox

protocol DropboxRepositoryProtocol {
    func handleSignIn() async throws
    func ensureSignedIn() async throws
    func signOut()
    func handleRedirectURL(_ url: URL, completion: @escaping (DropboxOAuthResult?) -> Void) -> Bool
    
    func uploadReport(folderPath: String, files: [DropboxFileInfo]?) -> AnyPublisher<DropboxUploadProgressInfo, APIError>
    func createFolder(name: String, description: String) -> AnyPublisher<String, APIError>
    
    func pauseUpload()
}

class DropboxRepository: DropboxRepositoryProtocol {
    private var client: DropboxClient?
    private var isCancelled = false
    private let networkMonitor: NetworkMonitor
    private var subscribers: Set<AnyCancellable> = []
    private let networkStatusSubject = PassthroughSubject<Bool, Never>()
    
    private var currentUploadTask: Task<Void, Error>?
    private var uploadProgressSubject = PassthroughSubject<DropboxUploadProgressInfo, APIError>()
    
    init(networkMonitor: NetworkMonitor = .shared) {
        self.networkMonitor = networkMonitor
        setupNetworkMonitor()
    }
    
    private func setupNetworkMonitor() {
        networkMonitor.connectionDidChange.sink { isConnected in
            self.networkStatusSubject.send(isConnected)
        }.store(in: &subscribers)
    }
    
    func setupDropbox() {
        guard let dropboxAppKey = ConfigurationManager.getValue(DropboxAuthConstants.dropboxAppKey) else  {
            debugLog("Dropbox App Key not found")
            
            return
        }
        
        DropboxClientsManager.setupWithAppKey(dropboxAppKey)
    }
    
    func handleRedirectURL(_ url: URL, completion: @escaping (DropboxOAuthResult?) -> Void) -> Bool {
        return DropboxClientsManager.handleRedirectURL(url, includeBackgroundClient: false, completion: completion)
    }
    func handleSignIn() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async {
                let scopeRequest = ScopeRequest(scopeType: .user, scopes: [DropboxAuthConstants.filesContentRead, DropboxAuthConstants.filesContentWrite], includeGrantedScopes: false)
                
                DropboxClientsManager.authorizeFromControllerV2(
                    UIApplication.shared,
                    controller: UIApplication.shared.rootViewController,
                    loadingStatusDelegate: nil,
                    openURL: { (url: URL) -> Void in
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    },
                    scopeRequest: scopeRequest
                )
                continuation.resume()
            }
        }
    }
    
    func createFolder(name: String, description: String) -> AnyPublisher<String, APIError> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        try await self.ensureSignedIn()
                        self.performCreateFolder(name: name, description: description, promise: promise)
                    } catch let apiError as APIError {
                        promise(.failure(apiError))
                    } catch {
                        if self.isDropboxAuthError(error) {
                            promise(.failure(.noToken))
                        } else {
                            promise(.failure(.dropboxApiError(error)))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func performCreateFolder(
        name: String,
        description: String,
        promise: @escaping (Result<String, APIError>) -> Void
    ) {
        guard let client = self.client else {
            promise(.failure(APIError.noToken))
            return
        }
        
        let folderPath = "/\(name)"
        
        // Create folder
        client.files.createFolderV2(path: folderPath, autorename: true).response { response, error in
            if let error = error {
                if self.isDropboxAuthError(error) {
                    promise(.failure(.noToken))
                } else {
                    promise(.failure(.dropboxApiError(error)))
                }
            } else if let metadata = response?.metadata {
                // Upload description file
                self.uploadDescriptionFile(
                    client: client,
                    folderPath: folderPath,
                    description: description,
                    folderId: metadata.id,
                    promise: promise
                )
            } else {
                promise(.failure(.errorOccured))
            }
        }
    }
    
    private func uploadDescriptionFile(
        client: DropboxClient,
        folderPath: String,
        description: String,
        folderId: String,
        promise: @escaping (Result<String, APIError>) -> Void
    ) {
        let descriptionData = description.data(using: .utf8) ?? Data()
        client.files.upload(path: "\(folderPath)/description.txt", input: descriptionData)
            .response { response, error in
                if let error = error {
                    if self.isDropboxAuthError(error) {
                        promise(.failure(.noToken))
                    } else {
                        promise(.failure(.dropboxApiError(error)))
                    }
                } else {
                    promise(.success(folderId))
                }
            }
    }
    
    
    func uploadReport(folderPath: String, files: [DropboxFileInfo]? = nil) -> AnyPublisher<DropboxUploadProgressInfo, APIError> {
        uploadProgressSubject = PassthroughSubject<DropboxUploadProgressInfo, APIError>()
        isCancelled = false

        let folderPathToUse = folderPath

        currentUploadTask = Task {
            var fileUploadStates: [FileUploadState]
            do {
                if let files = files {
                    fileUploadStates = files.map { fileInfo -> FileUploadState in
                        let fileSize = (try? FileManager.default.attributesOfItem(atPath: fileInfo.url.path)[.size] as? Int64) ?? 0
                        return FileUploadState(fileURL: fileInfo.url,
                                               fileName: fileInfo.fileName,
                                               fileId: fileInfo.fileId,
                                               sessionId: fileInfo.sessionId,
                                               offset: fileInfo.offset ?? 0,
                                               totalBytes: fileSize)
                    }
                } else {
                    throw APIError.errorOccured
                }

                try await self.ensureSignedIn()
                guard let client = self.client else {
                    throw APIError.noToken
                }

                for (index, fileState) in fileUploadStates.enumerated() {
                    
                    if isCancelled {
                        return
                    }

                    let totalBytes = fileState.totalBytes
                    let fileId = fileState.fileId

                    // Upload the file
                    try await self.uploadFile(client: client, folderPath: folderPathToUse, fileState: fileState, currentFileIndex: index) { progressInfo in
                        self.uploadProgressSubject.send(progressInfo)
                    }

                    // File upload completed
                    let completedInfo = DropboxUploadProgressInfo(
                        bytesSent: Int(totalBytes),
                        current: index + 1,
                        fileId: fileId,
                        status: .uploaded,
                        reportStatus: index == fileUploadStates.count - 1 ? .submitted : .submissionInProgress,
                        offset: fileState.offset,
                        sessionId: fileState.sessionId
                    )
                    self.uploadProgressSubject.send(completedInfo)
                }
                uploadProgressSubject.send(completion: .finished)
            }  catch let apiError as APIError {
                uploadProgressSubject.send(completion: .failure(apiError))
            }
            catch {
                if self.isDropboxAuthError(error) {
                    uploadProgressSubject.send(completion: .failure(.noToken))
                } else {
                    uploadProgressSubject.send(completion: .failure(.dropboxApiError(error)))
                }
            }
        }

        return uploadProgressSubject.eraseToAnyPublisher()
    }
    
    private func uploadFile(
        client: DropboxClient,
        folderPath: String,
        fileState: FileUploadState,
        currentFileIndex: Int,
        progressHandler: @escaping (DropboxUploadProgressInfo) -> Void
    ) async throws {
        try await uploadFileInChunks(client: client, folderPath: folderPath, fileState: fileState, currentFileIndex: currentFileIndex, progressHandler: progressHandler)
    }
    
    private func uploadFileInChunks(
        client: DropboxClient,
        folderPath: String,
        fileState: FileUploadState,
        currentFileIndex: Int,
        progressHandler: @escaping (DropboxUploadProgressInfo) -> Void
    ) async throws {
        let fileSize = fileState.totalBytes

        // Determine chunk size based on file size
        let chunkSize: Int64
        if fileSize <= 5 * 1024 * 1024 {
            // For files <= 5 MB, we'll upload the entire file in one chunk
            chunkSize = fileSize
        } else {
            // For larger files, use 5 MB chunks
            chunkSize = 5 * 1024 * 1024
        }

        var offset = fileState.offset
        var sessionId = fileState.sessionId

        let fileHandle = try FileHandle(forReadingFrom: fileState.fileURL)
        defer {
            try? fileHandle.close()
        }

        if offset > 0 {
            try fileHandle.seek(toOffset: UInt64(offset))
        }

        while offset < fileSize {
            if isCancelled {
                fileState.offset = offset
                fileState.sessionId = sessionId
                
                return
            }

            let remainingBytes = fileSize - offset
            let bytesToRead = min(chunkSize, remainingBytes)
            let data = try fileHandle.read(upToCount: Int(bytesToRead)) ?? Data()

            do {
                if sessionId == nil {
                    // Start upload session
                    if remainingBytes <= chunkSize {
                        let result = try await client.files.uploadSessionStart(close: false, input: data).response()
                        sessionId = result.sessionId
                        if let sessionId = sessionId {
                            fileState.sessionId = sessionId
                        } else {
                            throw APIError.errorOccured
                        }
                        offset += Int64(data.count)
                        fileState.offset = offset

                        // Finish upload session
                        let cursor = Files.UploadSessionCursor(sessionId: sessionId!, offset: UInt64(offset))
                        let commitInfo = Files.CommitInfo(path: "\(folderPath)/\(fileState.fileName)", mode: .add, autorename: false, mute: false)
                        try await client.files.uploadSessionFinish(cursor: cursor, commit: commitInfo, input: Data()).response()

                        fileState.offset = 0
                        debugLog("Finished upload session for file: \(fileState.fileName)")
                    } else {
                        // Start session for larger files
                        let result = try await client.files.uploadSessionStart(input: data).response()
                        sessionId = result.sessionId
                        if let sessionId = sessionId {
                            fileState.sessionId = sessionId
                        } else {
                            throw APIError.errorOccured
                        }
                        offset += Int64(data.count)
                        fileState.offset = offset
                    }
                } else {
                    let cursor = Files.UploadSessionCursor(sessionId: sessionId!, offset: UInt64(offset))
                    if remainingBytes <= chunkSize {
                        // Finish upload session
                        debugLog("Finishing upload session for file: \(fileState.fileName)")
                        let commitInfo = Files.CommitInfo(path: "\(folderPath)/\(fileState.fileName)", mode: .add, autorename: false, mute: false)
                        try await client.files.uploadSessionFinish(cursor: cursor, commit: commitInfo, input: data).response()

                        fileState.offset = 0
                        offset += Int64(data.count)
                        debugLog("Finished upload session for file: \(fileState.fileName)")
                    } else {
                        // Append to upload session
                        debugLog("Appending data to upload session for file: \(fileState.fileName), offset: \(offset)")
                        try await client.files.uploadSessionAppendV2(cursor: cursor, close: false, input: data).response()

                        offset += Int64(data.count)
                        fileState.offset = offset
                    }
                }
            } catch {
                // Error handling
                try handleUploadError(error, fileHandle: fileHandle, offset: &offset, fileState: fileState, sessionId: &sessionId)
            }

            // Send progress update
            let progressInfo = DropboxUploadProgressInfo(
                bytesSent: Int(offset),
                current: currentFileIndex + 1,
                fileId: fileState.fileId,
                status: .partialSubmitted,
                reportStatus: .submissionInProgress,
                offset: fileState.offset,
                sessionId: fileState.sessionId
            )
            progressHandler(progressInfo)
        }
    }
    
    private func handleUploadError(
        _ error: Error,
        fileHandle: FileHandle,
        offset: inout Int64,
        fileState: FileUploadState,
        sessionId: inout String?
    ) throws {
        debugLog(error)
        if self.isDropboxAuthError(error) {
            throw APIError.noToken
        }
        if let callError = error as? CallError<Files.UploadSessionAppendError> {
            debugLog(callError)
            switch callError {
            case .routeError(let boxedLookupError, _, _, _):
                let lookupError = boxedLookupError.unboxed
                switch lookupError {
                case .incorrectOffset(let incorrectOffsetError):
                    let correctOffset = incorrectOffsetError.correctOffset
                    debugLog("Received incorrect_offset error. Adjusting offset from \(offset) to \(correctOffset).")
                    offset = Int64(correctOffset)
                    fileState.offset = offset
                    try fileHandle.seek(toOffset: UInt64(offset))
                case .notFound:
                    debugLog("Upload session not found. Starting a new session.")
                    sessionId = nil
                    fileState.sessionId = nil
                default:
                    debugLog("Upload session error: \(lookupError)")
                    throw APIError.dropboxApiError(callError)
                }
            default:
                debugLog("Error during upload: \(callError)")
                throw APIError.dropboxApiError(callError)
            }
        } else {
            throw APIError.dropboxApiError(error)
        }
    }
    
    
    private func uploadData(client: DropboxClient, path: String, data: Data) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            client.files.upload(path: path, input: data)
                .response { response, error in
                    if let error = error {
                        debugLog("Error uploading data to \(path): \(error)")
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
        }
    }
        
    func pauseUpload() {
        isCancelled = true
        currentUploadTask?.cancel()
    }
    
    func ensureSignedIn() async throws {
        if self.client == nil {
            if let client = DropboxClientsManager.authorizedClient {
                self.client = client
            } else {
                try await handleSignIn()
            }
        }
    }
    
    func signOut() {
        DropboxClientsManager.unlinkClients()
        client = nil
    }
    
    private func isDropboxAuthError(_ error: Error) -> Bool {
        return isAuthError(error as? CallError<Files.UploadError>) ||
               isAuthError(error as? CallError<Files.CreateFolderError>) ||
               isAuthError(error as? CallError<Files.UploadSessionStartError>) ||
               isAuthError(error as? CallError<Files.UploadSessionFinishError>) ||
               isAuthError(error as? CallError<Files.UploadSessionAppendError>)
    }

    private func isAuthError<T>(_ callError: CallError<T>?) -> Bool {
        if let callError = callError, case .authError = callError {
            return true
        }
        return false
    }
}


