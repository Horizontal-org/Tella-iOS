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
    
    func uploadReport(folderPath: String, files: [(URL, String, String)]) -> AnyPublisher<UploadProgressInfo, Error>
    func createFolder(name: String, description: String) async throws -> String
    
    func pauseUpload()
    func resumeUpload() -> AnyPublisher<UploadProgressInfo, Error>

}

class DropboxRepository: DropboxRepositoryProtocol {
    private var client: DropboxClient?
    private var isCancelled = false
    private let networkMonitor: NetworkMonitor
    private var subscribers: Set<AnyCancellable> = []
    private let networkStatusSubject = PassthroughSubject<Bool, Never>()
    
    private var currentUploadTask: Task<Void, Error>?
    private var uploadProgressSubject = PassthroughSubject<UploadProgressInfo, Error>()
    private var pausedUploadState: PausedUploadState?
    
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
        try await self.uploadFile(client: client, path: "\(folderPath)/description.txt", data: descriptionData) { _ in }
        
        return folderId
    }
    
    func uploadReport(folderPath: String, files: [(URL, String, String)]) -> AnyPublisher<UploadProgressInfo, Error> {
            pausedUploadState = nil
            isCancelled = false
            
            currentUploadTask = Task {
                do {
                    try await self.ensureSignedIn()
                    guard let client = self.client else {
                        throw NSError(domain: "DropboxRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Dropbox client is not initialized"])
                    }
                    
                    for (index, (fileURL, fileName, fileId)) in files.enumerated() {
                        if isCancelled {
                            pausedUploadState = PausedUploadState(folderPath: folderPath, files: files, currentFileIndex: index)
                            throw NSError(domain: "DropboxRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Upload paused"])
                        }
                        
                        let fileData = try Data(contentsOf: fileURL)
                        var bytesSent: Int64 = 0
                        let totalBytes = Int64(fileData.count)
                        
                        try await self.uploadFile(client: client, path: "\(folderPath)/\(fileName)", data: fileData) { progress in
                            bytesSent = Int64(Double(totalBytes) * progress)
                            let progressInfo = UploadProgressInfo(
                                bytesSent: Int(bytesSent),
                                current: index + 1,
                                fileId: fileId,
                                status: .partialSubmitted,
                                reportStatus: .submissionInProgress
                            )
                            self.uploadProgressSubject.send(progressInfo)
                        }
                        
                        let completedInfo = UploadProgressInfo(
                            bytesSent: Int(totalBytes),
                            current: index + 1,
                            fileId: fileId,
                            status: .uploaded,
                            reportStatus: index == files.count - 1 ? .submitted : .submissionInProgress
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

        
    private func uploadFile(client: DropboxClient, path: String, data: Data, progressHandler: @escaping (Double) -> Void) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            client.files.upload(path: path, input: data)
                .progress { progressData in
                    progressHandler(progressData.fractionCompleted)
                }
                .response { response, error in
                    if let error = error {
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
        
    func resumeUpload() -> AnyPublisher<UploadProgressInfo, Error> {
        guard let pausedState = pausedUploadState else {
            return Fail(error: NSError(domain: "DropboxRepository", code: 2, userInfo: [NSLocalizedDescriptionKey: "No paused upload to resume"])).eraseToAnyPublisher()
        }
        
        let remainingFiles = Array(pausedState.files[pausedState.currentFileIndex...])
        return uploadReport(folderPath: pausedState.folderPath, files: remainingFiles)
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

struct PausedUploadState {
    let folderPath: String
    let files: [(URL, String, String)]
    let currentFileIndex: Int
}
