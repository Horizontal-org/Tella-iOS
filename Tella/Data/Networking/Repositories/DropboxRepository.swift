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
    
    func uploadReport(folderPath: String, files: [(URL, String, String, Int64?, String?)]?) -> AnyPublisher<DropboxUploadProgressInfo, Error>
    func createFolder(name: String, description: String) async throws -> String
    
    func pauseUpload()
}

class DropboxRepository: DropboxRepositoryProtocol {
    private var client: DropboxClient?
    private var isCancelled = false
    private let networkMonitor: NetworkMonitor
    private var subscribers: Set<AnyCancellable> = []
    private let networkStatusSubject = PassthroughSubject<Bool, Never>()
    
    private var currentUploadTask: Task<Void, Error>?
    private var uploadProgressSubject = PassthroughSubject<DropboxUploadProgressInfo, Error>()
    
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
    
    func createFolder(name: String, description: String) async throws -> String {
        try await self.ensureSignedIn()
        guard let client = self.client else {
            throw NSError(domain: "DropboxRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Dropbox client is not initialized"])
        }
        
        let folderPath = "/\(name)"
        
        // Create folder
        let folderId = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            client.files.createFolderV2(path: folderPath, autorename: true).response { response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let metadata = response?.metadata {
                    continuation.resume(returning: metadata.id)
                } else {
                    continuation.resume(throwing: NSError(domain: "DropboxRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create folder"]))
                }
            }
        }
        
        // Upload description file
        let descriptionData = description.data(using: .utf8) ?? Data()
        try await self.uploadData(client: client, path: "\(folderPath)/description.txt", data: descriptionData)
        
        return folderId
    }
    
    func uploadReport(folderPath: String, files: [(URL, String, String, Int64?, String?)]? = nil) -> AnyPublisher<DropboxUploadProgressInfo, Error> {
        uploadProgressSubject = PassthroughSubject<DropboxUploadProgressInfo, Error>()
        isCancelled = false

        let folderPathToUse = folderPath

        currentUploadTask = Task {
            var fileUploadStates: [FileUploadState]
            do {
                if let files = files {
                    fileUploadStates = files.map { (fileURL, fileName, fileId, offset, sessionId) -> FileUploadState in
                        let fileSize = (try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64) ?? 0
                        return FileUploadState(fileURL: fileURL, fileName: fileName, fileId: fileId, sessionId: sessionId, offset: offset ?? 0, totalBytes: fileSize)
                    }
                } else {
                    // No files to upload
                    throw NSError(domain: "DropboxRepository", code: 3, userInfo: [NSLocalizedDescriptionKey: "No files to upload"])
                }

                try await self.ensureSignedIn()
                guard let client = self.client else {
                    throw NSError(domain: "DropboxRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Dropbox client is not initialized"])
                }

                for (index, fileState) in fileUploadStates.enumerated() {
                    if isCancelled {
                        // Save the current state of each file if necessary
                        throw NSError(domain: "DropboxRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Upload paused"])
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
            } catch {
                uploadProgressSubject.send(completion: .failure(error))
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
        let fileSize = fileState.totalBytes
        let fileURL = fileState.fileURL
        let path = "\(folderPath)/\(fileState.fileName)"
        let fileName = fileState.fileName
        
        if fileSize <= 150 * 1024 * 1024 {
            guard let inputStream = InputStream(fileAtPath: fileURL.path) else {
                throw NSError(domain: "DropboxRepository", code: 5, userInfo: [NSLocalizedDescriptionKey: "Unable to create input stream for file: \(fileName)"])
            }
            
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                client.files.upload(path: path, input: inputStream)
                    .progress { progressData in
                        let progress = progressData.fractionCompleted
                        let bytesSent = Int64(Double(fileSize) * progress)
                        fileState.offset = bytesSent
                        
                        let progressInfo = DropboxUploadProgressInfo(
                            bytesSent: Int(bytesSent),
                            current: currentFileIndex + 1,
                            fileId: fileState.fileId,
                            status: .partialSubmitted,
                            reportStatus: .submissionInProgress,
                            offset: fileState.offset,
                            sessionId: fileState.sessionId
                        )
                        progressHandler(progressInfo)
                    }
                    .response { response, error in
                        if let error = error {
                            debugLog("Error uploading small file \(fileName): \(error)")
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                    }
            }
            fileState.offset = fileSize
        } else {
            try await uploadFileInChunks(client: client, folderPath: folderPath, fileState: fileState, currentFileIndex: currentFileIndex, progressHandler: progressHandler)
        }
    }
    
    private func uploadFileInChunks(
        client: DropboxClient,
        folderPath: String,
        fileState: FileUploadState,
        currentFileIndex: Int,
        progressHandler: @escaping (DropboxUploadProgressInfo) -> Void
    ) async throws {
        let chunkSize: Int64 = 5 * 1024 * 1024
        let fileSize = fileState.totalBytes

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
                throw NSError(domain: "DropboxRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Upload paused"])
            }

            let remainingBytes = fileSize - offset
            let bytesToRead = min(chunkSize, remainingBytes)
            let data = try fileHandle.read(upToCount: Int(bytesToRead)) ?? Data()

            do {
                if sessionId == nil {
                    debugLog("Starting upload session for file: \(fileState.fileName)")
                    let result = try await client.files.uploadSessionStart(input: data).response()
                    sessionId = result.sessionId
                    if let sessionId = sessionId {
                        fileState.sessionId = sessionId
                        debugLog("Started upload session with ID: \(sessionId)")
                    } else {
                        throw NSError(domain: "DropboxRepository", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to start upload session"])
                    }
                    offset += Int64(data.count)
                    fileState.offset = offset
                } else {
                    let cursor = Files.UploadSessionCursor(sessionId: sessionId!, offset: UInt64(offset))
                    if remainingBytes <= chunkSize {
                        debugLog("Finishing upload session for file: \(fileState.fileName)")
                        let commitInfo = Files.CommitInfo(path: "\(folderPath)/\(fileState.fileName)", mode: .add, autorename: false, mute: false)
                        try await client.files.uploadSessionFinish(cursor: cursor, commit: commitInfo, input: data).response()

                        fileState.sessionId = nil
                        fileState.offset = 0
                        offset += Int64(data.count)
                        debugLog("Finished upload session for file: \(fileState.fileName)")
                    } else {
                        debugLog("Appending data to upload session for file: \(fileState.fileName), offset: \(offset)")
                        try await client.files.uploadSessionAppendV2(cursor: cursor, close: false, input: data).response()

                        offset += Int64(data.count)
                        fileState.offset = offset
                    }
                }
            } catch {
                if let callError = error as? CallError<Files.UploadSessionAppendError> {
                    debugLog(callError)
                    switch callError {
                    case .routeError(let boxedLookupError, _, _, _):
                        let lookupError = boxedLookupError.unboxed
                        debugLog(lookupError)
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
                            throw callError
                        }
                    default:
                        debugLog("Error during upload of file \(fileState.fileName): \(callError)")
                        throw callError
                    }
                } else {
                    throw error
                }
            }

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
}



// mmove this to a separate model

class DropboxUploadProgressInfo: UploadProgressInfo {
    var offset: Int64?
    var sessionId: String?

    init(bytesSent: Int?,
         current: Int,
         fileId: String,
         status: FileStatus,
         reportStatus: ReportStatus,
         offset: Int64?,
         sessionId: String?) {
        self.offset = offset
        self.sessionId = sessionId
        super.init(bytesSent: bytesSent, current: current, fileId: fileId, status: status, reportStatus: reportStatus)
    }
}

class FileUploadState {
    let fileURL: URL
    let fileName: String
    let fileId: String
    var sessionId: String?
    var offset: Int64
    let totalBytes: Int64
    
    init(fileURL: URL, fileName: String, fileId: String, sessionId: String?, offset: Int64, totalBytes: Int64) {
        self.fileURL = fileURL
        self.fileName = fileName
        self.fileId = fileId
        self.sessionId = sessionId
        self.offset = offset
        self.totalBytes = totalBytes
    }
}

struct PausedUploadState {
    let folderPath: String
    let files: [FileUploadState]
    let currentFileIndex: Int
}
