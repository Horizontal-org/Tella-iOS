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
    
    func uploadReport(folderPath: String, files: [(URL, String, String)]?, pausedState: PausedUploadState?) -> AnyPublisher<UploadProgressInfo, Error>
    func createFolder(name: String, description: String) async throws -> String
    
    func pauseUpload()
    
    func resumeUpload(folderPath: String) -> AnyPublisher<UploadProgressInfo, Error>

    var pausedUploadState: PausedUploadState? { get }
}

class DropboxRepository: DropboxRepositoryProtocol {
    private var client: DropboxClient?
    private var isCancelled = false
    private let networkMonitor: NetworkMonitor
    private var subscribers: Set<AnyCancellable> = []
    private let networkStatusSubject = PassthroughSubject<Bool, Never>()
    
    private var currentUploadTask: Task<Void, Error>?
    private var uploadProgressSubject = PassthroughSubject<UploadProgressInfo, Error>()
    private(set) var pausedUploadState: PausedUploadState?
    
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
    
    func uploadReport(folderPath: String, files: [(URL, String, String)]? = nil, pausedState: PausedUploadState? = nil) -> AnyPublisher<UploadProgressInfo, Error> {
        uploadProgressSubject = PassthroughSubject<UploadProgressInfo, Error>()
        isCancelled = false
        pausedUploadState = nil

        let folderPathToUse: String

        if let pausedState = pausedState {
            folderPathToUse = pausedState.folderPath
        } else if files != nil {
            folderPathToUse = folderPath
        } else {
            // No files to upload
            return Fail(error: NSError(domain: "DropboxRepository", code: 3, userInfo: [NSLocalizedDescriptionKey: "No files to upload"])).eraseToAnyPublisher()
        }

        currentUploadTask = Task {
            var fileUploadStates: [FileUploadState]
            do {
                if let pausedState = pausedState {
                    fileUploadStates = pausedState.files
                } else if let files = files {
                    fileUploadStates = files.map { (fileURL, fileName, fileId) -> FileUploadState in
                        let fileSize = (try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64) ?? 0
                        return FileUploadState(fileURL: fileURL, fileName: fileName, fileId: fileId, sessionId: nil, offset: 0, totalBytes: fileSize)
                    }
                } else {
                    // No files to upload
                    throw NSError(domain: "DropboxRepository", code: 3, userInfo: [NSLocalizedDescriptionKey: "No files to upload"])
                }

                try await self.ensureSignedIn()
                guard let client = self.client else {
                    throw NSError(domain: "DropboxRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Dropbox client is not initialized"])
                }

                let startIndex = pausedState?.currentFileIndex ?? 0

                for index in startIndex..<fileUploadStates.count {
                    if isCancelled {
                        pausedUploadState = PausedUploadState(folderPath: folderPathToUse, files: fileUploadStates, currentFileIndex: index)
                        throw NSError(domain: "DropboxRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Upload paused"])
                    }

                    let totalBytes = fileUploadStates[index].totalBytes
                    let fileId = fileUploadStates[index].fileId

                    // Upload the file
                    try await self.uploadFile(client: client, folderPath: folderPathToUse, fileState: &fileUploadStates[index]) { progress in
                        let bytesSent = Int64(Double(totalBytes) * progress)
                        let progressInfo = UploadProgressInfo(
                            bytesSent: Int(bytesSent),
                            current: index + 1,
                            fileId: fileId,
                            status: .partialSubmitted,
                            reportStatus: .submissionInProgress
                        )
                        self.uploadProgressSubject.send(progressInfo)
                    }

                    // File upload completed
                    let completedInfo = UploadProgressInfo(
                        bytesSent: Int(totalBytes),
                        current: index + 1,
                        fileId: fileId,
                        status: .uploaded,
                        reportStatus: index == fileUploadStates.count - 1 ? .submitted : .submissionInProgress
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
    
    private func uploadFile(client: DropboxClient, folderPath: String, fileState: inout FileUploadState, progressHandler: @escaping (Double) -> Void) async throws {
        let fileSize = fileState.totalBytes
        let fileURL = fileState.fileURL
        let path = "\(folderPath)/\(fileState.fileName)"
        let fileName = fileState.fileName

        // Use standard upload for files <= 150 MB
        if fileSize <= 150 * 1024 * 1024 {
            guard let inputStream = InputStream(fileAtPath: fileURL.path) else {
                throw NSError(domain: "DropboxRepository", code: 5, userInfo: [NSLocalizedDescriptionKey: "Unable to create input stream for file: \(fileName)"])
            }

            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                client.files.upload(path: path, input: inputStream)
                    .progress { progressData in
                        let progress = progressData.fractionCompleted
                        let bytesSent = Int64(Double(fileSize) * progress)
                        progressHandler(progress)
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
            try await uploadFileInChunks(client: client, folderPath: folderPath, fileState: &fileState, progressHandler: progressHandler)
        }
    }
    
    private func uploadFileInChunks(client: DropboxClient, folderPath: String, fileState: inout FileUploadState, progressHandler: @escaping (Double) -> Void) async throws {
        let chunkSize: Int64 = 5 * 1024 * 1024 // 5 MB
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
            } catch let error {
                debugLog("Error during upload of file \(fileState.fileName): \(error)")
                throw error
            }

            let progress = Double(offset) / Double(fileSize)
            progressHandler(progress)
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
    
    func resumeUpload(folderPath: String) -> AnyPublisher<UploadProgressInfo, Error> {
        guard let pausedState = pausedUploadState else {
            return Fail(error: NSError(domain: "DropboxRepository", code: 2, userInfo: [NSLocalizedDescriptionKey: "No paused upload to resume"])).eraseToAnyPublisher()
        }

        return uploadReport(folderPath: folderPath, pausedState: pausedState)
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

struct FileUploadState {
    let fileURL: URL
    let fileName: String
    let fileId: String
    var sessionId: String?
    var offset: Int64
    let totalBytes: Int64
}

struct PausedUploadState {
    let folderPath: String
    let files: [FileUploadState]
    let currentFileIndex: Int
}
