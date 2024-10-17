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
    
    func submitReport(report: DropboxReportToSend) -> AnyPublisher<DropboxUploadResponse, APIError>
    
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
    
    private let descriptionFolderName = "description.txt"
    private let chunkSize: Int64 = 1024 * 1024
    
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
    
    func submitReport(report: DropboxReportToSend) -> AnyPublisher<DropboxUploadResponse, APIError> {
        let subject = PassthroughSubject<DropboxUploadResponse, APIError>()
        
        isCancelled = false
        
        Task {
            do {
                
                try checkInternetConnection()
                
                try await ensureSignedIn()
                
                switch report.remoteReportStatus {
                    
                case .initial, .unknown :
                    try await handleInitialOrUnknownStatus(report: report, subject: subject)
                    
                case .created:
                    try await handleCreatedStatus(report: report, subject: subject)
                    
                default:
                    break
                }
                
                if report.files.isEmpty {
                    subject.send(completion:.finished)
                }
                
                guard !isCancelled else { return }
                
                try checkInternetConnection()
                
                uploadFiles(report: report, subject: subject)
                
                monitorNetworkConnection(subject: subject)
                
            } catch let apiError as APIError {
                subject.send(completion: .failure(apiError))
            } catch {
                subject.send(completion: .failure(.unexpectedResponse))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    private func handleInitialOrUnknownStatus(report: DropboxReportToSend,
                                              subject: PassthroughSubject<DropboxUploadResponse, APIError>) async throws {
        
        guard !isCancelled else { return }
        
        let folderName = try await createFolder(name: report.name)
        subject.send(.folderCreated(folderName: folderName))
        
        guard !isCancelled else { return }
        
        report.name = folderName
        
        try await uploadDescriptionFile(report: report)
        subject.send(.descriptionSent)
        
    }
    
    private func handleCreatedStatus(report: DropboxReportToSend,
                                     subject: PassthroughSubject<DropboxUploadResponse, APIError>) async throws {
        
        guard !isCancelled else { return }
        
        try await uploadDescriptionFile(report: report)
        subject.send(.descriptionSent)
    }
    
    private func createFolder(name: String) async throws -> String {
        
        try checkInternetConnection()
        
        guard let client = self.client else {
            throw APIError.noToken
        }
        
        let folderPath = name.preffixedSlash()
        
        return   try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            client.files.createFolderV2(path: folderPath, autorename: true).response { response, error in
                if let error = error {
                    if self.isDropboxAuthError(error) {
                        continuation.resume(throwing: APIError.noToken)
                    } else {
                        continuation.resume(throwing: APIError.dropboxApiError(error))
                    }
                } else if let name = response?.metadata.name {
                    continuation.resume(returning: name)
                } else {
                    continuation.resume(throwing: APIError.errorOccured)
                }
            }
        }
    }
    
    private func uploadDescriptionFile(report: DropboxReportToSend) async throws {
        
        try checkInternetConnection()
        
        guard let client = self.client else {
            throw APIError.noToken
        }
        
        guard let descriptionData = report.description.data else {
            return
        }
        let reportFolderPath = report.name.preffixedSlash()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            client.files.upload(path: reportFolderPath.slash() + descriptionFolderName, input: descriptionData)
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
    
    private func uploadFiles(report: DropboxReportToSend, subject: PassthroughSubject<DropboxUploadResponse, APIError>) {
        
        report.files.forEach { file in
            uploadFileInChunks(file: file, folderName: report.name)
                .sink(receiveCompletion: { completion in
                    
                }, receiveValue: { result in
                    subject.send(.progress(progressInfo: result))
                }).store(in: &subscribers)
        }
    }
    
    private func uploadFileInChunks(file: DropboxFileInfo,
                                    folderName: String ) -> CurrentValueSubject<DropboxUploadProgressInfo,APIError>  {
        
        let progressInfo = DropboxUploadProgressInfo(fileId: file.fileId, status: FileStatus.partialSubmitted)
        
        let subject = CurrentValueSubject<DropboxUploadProgressInfo, APIError>(progressInfo)
        
        Task {
            
            try checkInternetConnection()
            
            let fileSize = file.totalBytes
            var offset = file.offset
            var sessionId = file.sessionId
            
            let fileHandle = try FileHandle(forReadingFrom: file.url)
            defer { try? fileHandle.close() }
            
            while offset < fileSize {
                
                if isCancelled {
                    return
                }
                
                let data = try fileHandle.readChunk(from: offset, chunkSize: chunkSize, fileSize: fileSize)
                let remainingBytes = fileSize - offset
                
                await processChunkUpload(file: file,
                                         folderName: folderName,
                                         data: data,
                                         remainingBytes: remainingBytes,
                                         sessionId: &sessionId,
                                         offset: &offset,
                                         progressInfo: progressInfo,
                                         subject: subject)
            }
            
            progressInfo.status = .uploaded
            subject.send(progressInfo)
        }
        
        return subject
    }
    
    private func processChunkUpload(file: DropboxFileInfo,
                                    folderName: String,
                                    data: Data,
                                    remainingBytes: Int64,
                                    sessionId: inout String?,
                                    offset: inout Int64,
                                    progressInfo:  DropboxUploadProgressInfo,
                                    subject: CurrentValueSubject<DropboxUploadProgressInfo, APIError>) async {
        
        guard let client = self.client else {
            progressInfo.error = APIError.noToken
            return
        }
        
        do {
            
            // Append to upload session
            if sessionId != nil && remainingBytes > chunkSize {
                let cursor = Files.UploadSessionCursor(sessionId: sessionId!, offset: UInt64(offset))
                debugLog("Appending data to upload session for file: \(file.fileName), offset: \(offset)")
                try await client.files.uploadSessionAppendV2(cursor: cursor, input: data).response()
                offset += Int64(data.count)
                
            } else {
                
                var dataToSend = data
                
                // Start upload session
                if sessionId == nil {
                    let result = try await client.files.uploadSessionStart(input: data).response()
                    sessionId = result.sessionId
                    offset += Int64(data.count)
                    dataToSend = Data()
                }
                if remainingBytes <= chunkSize {
                    // Finish upload session
                    let cursor = Files.UploadSessionCursor(sessionId: sessionId!, offset: UInt64(offset))
                    let commitInfo = Files.CommitInfo(path: folderName.preffixedSlash().slash() + file.fileName, mode: .add, autorename: false, mute: false)
                    let _ = try await client.files.uploadSessionFinish(cursor: cursor, commit: commitInfo, input: dataToSend).response()
                    offset += Int64(data.count)
                    debugLog("Finished upload session for file: \(file.fileName)")
                }
            }
            progressInfo.sessionId = sessionId
            progressInfo.status = .partialSubmitted
            progressInfo.bytesSent = Int(offset)
            subject.send(progressInfo)
            
        } catch let apiError as APIError {
            debugLog("Caught APIError during chunk upload: \(apiError)")
            progressInfo.error = apiError
            subject.send(progressInfo)
        } catch {
            // Error handling for dropbox specific errors
            if let error = handleUploadError(error, offset: &offset, sessionId: &sessionId) {
                progressInfo.error = error
                subject.send(progressInfo)
            }
        }
    }
    
    private func handleUploadError(_ error: Error,
                                   offset: inout Int64,
                                   sessionId: inout String?) -> APIError? {
        
        if self.isDropboxAuthError(error) {
            return APIError.noToken
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
                case .notFound:
                    debugLog("Upload session not found. Starting a new session.")
                    sessionId = nil
                default:
                    debugLog("Upload session error: \(lookupError)")
                    return APIError.dropboxApiError(callError)
                }
            default:
                debugLog("Error during upload: \(callError)")
                return APIError.dropboxApiError(callError)
            }
        } else {
            return APIError.dropboxApiError(error)
        }
        return nil
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
    
    private func monitorNetworkConnection(subject: PassthroughSubject<DropboxUploadResponse, APIError>) {
        self.networkStatusSubject
            .filter { !$0 }
            .first()
            .sink { _ in
                self.handleNetworkLoss()
                subject.send(completion: .failure(.noInternetConnection))
            }
            .store(in: &self.subscribers)
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
    
    private func checkInternetConnection() throws {
        guard self.networkMonitor.isConnected else {
            throw APIError.noInternetConnection
        }
    }
    
}
