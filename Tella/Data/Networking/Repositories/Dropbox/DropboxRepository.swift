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
    
    func submitReport(folderId: String?, name: String, description: String, files: [DropboxFileInfo]? ) -> AnyPublisher<DropboxUploadResponse, APIError>
    
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
            if !isConnected {
                self.handleNetworkLoss()
            }
        }.store(in: &subscribers)
    }
    
    private func handleNetworkLoss() {
        isCancelled = true
        currentUploadTask?.cancel()
        uploadProgressSubject.send(completion: .failure(.noInternetConnection))
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
    
    func submitReport(folderId: String?, name: String, description: String, files: [DropboxFileInfo]?) -> AnyPublisher<DropboxUploadResponse, APIError> {
        let subject = PassthroughSubject<DropboxUploadResponse, APIError>()
        networkStatusSubject
                .filter { !$0 }
                .first()
                .sink { [weak self] _ in
                    self?.handleNetworkLoss()
                    subject.send(completion: .failure(.noInternetConnection))
                }
                .store(in: &subscribers)
        Task {
            do {
                try await ensureSignedIn()
                subject.send(.initial)
                isCancelled = false
                
                // Create folder or use existing folder
                let folderResponse: DropboxCreateFolderResponse
                if let folderId = folderId {
                    folderResponse = DropboxCreateFolderResponse(id: folderId, name: name)
                } else {
                    folderResponse = try await createFolder(name: name, description: description)
                    subject.send(.folderCreated(folderId: folderResponse.id, folderName: folderResponse.name))
                }
                
                // Upload files
                try await uploadFiles(
                    to: folderResponse.name.preffixedSlash(),
                    files: files,
                    subject: subject
                )
                subject.send(.finished)
            } catch let apiError as APIError {
                subject.send(completion: .failure(apiError))
            } catch {
                subject.send(completion: .failure(.unexpectedResponse))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func createFolder(name: String, description: String) async throws -> DropboxCreateFolderResponse {
        guard self.networkMonitor.isConnected else {
            throw APIError.noInternetConnection
        }
        
        try await ensureSignedIn()
        return try await performCreateFolder(name: name, description: description)
    }
    
    private func performCreateFolder(name: String, description: String) async throws -> DropboxCreateFolderResponse {
        guard let client = self.client else {
            throw APIError.noToken
        }
        
        let folderPath = name.preffixedSlash()
        
        let metadata = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Files.FolderMetadata, Error>) in
            client.files.createFolderV2(path: folderPath, autorename: true).response { response, error in
                if let error = error {
                    if self.isDropboxAuthError(error) {
                        continuation.resume(throwing: APIError.noToken)
                    } else {
                        continuation.resume(throwing: APIError.dropboxApiError(error))
                    }
                } else if let metadata = response?.metadata {
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: APIError.errorOccured)
                }
            }
        }
        
        let folderId = metadata.id
        let folderName = metadata.name
        
        // Upload the description file if it exists
        try await uploadDescriptionFile(client: client, folderPath: folderName.preffixedSlash(), description: description)
        
        return DropboxCreateFolderResponse(id: folderId, name: folderName)
    }
    
    private func uploadDescriptionFile(
        client: DropboxClient,
        folderPath: String,
        description: String
    ) async throws {
        let descriptionData = description.data(using: .utf8) ?? Data()
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            client.files.upload(path: "\(folderPath)/description.txt", input: descriptionData)
                .response { response, error in
                    if let error = error {
                        if self.isDropboxAuthError(error) {
                            continuation.resume(throwing: APIError.noToken)
                        } else {
                            continuation.resume(throwing: APIError.dropboxApiError(error))
                        }
                    } else {
                        continuation.resume(returning: ())
                    }
                }
        }
    }
    
    private func uploadFiles(
        to folderPath: String,
        files: [DropboxFileInfo]?,
        subject: PassthroughSubject<DropboxUploadResponse, APIError>
    ) async throws {
        guard let files = files else {
            throw APIError.errorOccured
        }

        try await ensureSignedIn()
        guard let client = self.client else {
            throw APIError.noToken
        }

        for (index, file) in files.enumerated() {
            if isCancelled {
                return
            }

            let fileState = FileUploadState(
                fileURL: file.url,
                fileName: file.fileName,
                fileId: file.fileId,
                sessionId: file.sessionId,
                offset: file.offset ?? 0,
                totalBytes: (try? FileManager.default.attributesOfItem(atPath: file.url.path)[.size] as? Int64) ?? 0
            )
            
            do {
                try await uploadFile(
                    client: client,
                    folderPath: folderPath,
                    fileState: fileState,
                    currentFileIndex: index
                ) { progressInfo in
                    subject.send(.progress(progressInfo: progressInfo))
                }
                
                // Emit completion for each file
                let completedInfo = DropboxUploadProgressInfo(
                    bytesSent: Int(fileState.totalBytes),
                    current: index + 1,
                    fileId: fileState.fileId,
                    status: .uploaded,
                    reportStatus: index == files.count - 1 ? .submitted : .submissionInProgress,
                    sessionId: fileState.sessionId
                )
                subject.send(.progress(progressInfo: completedInfo))
            } catch {
                subject.send(completion: .failure(error as? APIError ?? .unexpectedResponse))
                throw error
            }
        }
    }
    
    private func uploadFile(
        client: DropboxClient,
        folderPath: String,
        fileState: FileUploadState,
        currentFileIndex: Int,
        progressHandler: @escaping (DropboxUploadProgressInfo) -> Void
    ) async throws {
        try await uploadFileInChunks(
            client: client,
            folderPath: folderPath,
            fileState: fileState,
            currentFileIndex: currentFileIndex,
            progressHandler: progressHandler
        )
    }
    
    private func uploadFileInChunks(
        client: DropboxClient,
        folderPath: String,
        fileState: FileUploadState,
        currentFileIndex: Int,
        progressHandler: @escaping (DropboxUploadProgressInfo) -> Void
    ) async throws {
        guard self.networkMonitor.isConnected else {
            throw APIError.noInternetConnection
        }
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
            } catch let apiError as APIError {
                debugLog("Caught APIError during chunk upload: \(apiError)")
                throw apiError
            } catch {
                // Error handling for dropbox specific errors
                try handleUploadError(error, fileHandle: fileHandle, offset: &offset, fileState: fileState, sessionId: &sessionId)
            }

            // Send progress update
            let progressInfo = DropboxUploadProgressInfo(
                bytesSent: Int(offset),
                current: currentFileIndex + 1,
                fileId: fileState.fileId,
                status: .partialSubmitted,
                reportStatus: .submissionInProgress,
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
