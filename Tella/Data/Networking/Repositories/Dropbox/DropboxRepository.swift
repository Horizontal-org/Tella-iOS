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


typealias UploadSessionStart = UploadRequest<Files.UploadSessionStartResultSerializer, Files.UploadSessionStartErrorSerializer>
typealias UploadSessionAppend = UploadRequest<VoidSerializer, Files.UploadSessionAppendErrorSerializer>
typealias UploadSessionFinish = UploadRequest<Files.FileMetadataSerializer, Files.UploadSessionFinishErrorSerializer>
typealias UploadError = CallError<Files.UploadError>
typealias CreateFolderError = CallError<Files.CreateFolderError>
typealias UploadSessionStartError = CallError<Files.UploadSessionStartError>
typealias UploadSessionFinishError = CallError<Files.UploadSessionFinishError>
typealias UploadSessionAppendError = CallError<Files.UploadSessionAppendError>

class DropboxRepository: DropboxRepositoryProtocol {
    
    private var client: DropboxClient?
    private var isCancelled = false
    private let networkMonitor: NetworkMonitor
    private var subscribers: Set<AnyCancellable> = []
    private let networkStatusSubject = PassthroughSubject<Bool, Never>()
    
    private var uploadProgressSubject = PassthroughSubject<DropboxUploadProgressInfo, APIError>()
    
    private var uploadRequests : [String: [Any]]  = [:]
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
        pauseUpload()
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
                    subject.send(completion: completion)
                }, receiveValue: { result in
                    subject.send(.progress(progressInfo: result))
                }).store(in: &subscribers)
        }
    }
    
    private func uploadFileInChunks(file: DropboxFileInfo,
                                    folderName: String ) -> CurrentValueSubject<DropboxUploadProgressInfo,APIError>  {
        
        let progressInfo = DropboxUploadProgressInfo(fileId: file.fileId, status: FileStatus.partialSubmitted)
        
        let subject = CurrentValueSubject<DropboxUploadProgressInfo, APIError>(progressInfo)
        
        var tokenExpired :Bool  = false
        
        Task {
            
            try checkInternetConnection()
            
            let fileSize = file.totalBytes
            
            let fileHandle = try FileHandle(forReadingFrom: file.url)
            defer { try? fileHandle.close() }
            
            while file.offset < fileSize {
                do {
                    
                    if isCancelled {
                        return
                    }
                    
                    let data = try fileHandle.readChunk(from: file.offset, chunkSize: chunkSize, fileSize: fileSize)
                    let remainingBytes = fileSize - file.offset
                    
                    try await processChunkUpload(file: file,
                                                 folderName: folderName,
                                                 data: data,
                                                 remainingBytes: remainingBytes,
                                                 progressInfo: progressInfo,
                                                 subject: subject)
                    
                }  catch {

                    if self.isDropboxAuthError(error) {
                        tokenExpired = true
                        progressInfo.finishUploading = true
                        subject.send(completion: .failure(APIError.noToken))
                        return
                    }
                    
                    // Handle specific Dropbox errors
                    if let error = handleUploadError(error, file: file) {
                        progressInfo.error = error
                        progressInfo.status = .submissionError
                        progressInfo.finishUploading = true
                        subject.send(progressInfo)
                        return
                    }
                }
            }
            
            progressInfo.status = .uploaded
            subject.send(progressInfo)
            progressInfo.finishUploading = true
        }
        
        return subject
    }
    
    private func processChunkUpload(file: DropboxFileInfo,
                                    folderName: String,
                                    data: Data,
                                    remainingBytes: Int64,
                                    progressInfo: DropboxUploadProgressInfo,
                                    subject: CurrentValueSubject<DropboxUploadProgressInfo, APIError>) async throws {
        
        guard let client = self.client else {
            progressInfo.error = APIError.noToken
            return
        }
        
        // Append to upload session
        if file.sessionId != nil && remainingBytes > chunkSize {
            // Append to existing upload session
            try await appendToUploadSession(client: client, file: file, data: data)
            
        } else {
            
            // Start upload session
            if file.sessionId == nil {
                // Start a new upload session
                try await startUploadSession(file: file, client: client, data: data)
            }
            if remainingBytes <= chunkSize {
                // Finish upload session
                try await finishUploadSession(client: client, file: file, folderName: folderName, data: data)
            }
        }
        
        progressInfo.sessionId = file.sessionId
        progressInfo.status = .partialSubmitted
        progressInfo.bytesSent = Int(file.offset)
        subject.send(progressInfo)
        
    }
    
    private func startUploadSession(file: DropboxFileInfo,client: DropboxClient, data: Data) async throws {
        
        let request = client.files.uploadSessionStart(input: data)
        
        addRequest(file: file, request: request)
        
        let response = try await request.response()
        
        removeRequest(file: file)
        file.sessionId = response.sessionId
        file.offset += Int64(data.count)
    }
    
    private func addRequest(file:DropboxFileInfo, request:Any) {
        if var array = uploadRequests[file.fileId] {
            array.append(request)
        } else {
            uploadRequests[file.fileId] = [request]
        }
    }
    
    private func removeRequest(file:DropboxFileInfo) {
        uploadRequests.removeValue(forKey: file.fileId)
    }
    
    private func appendToUploadSession(client: DropboxClient, file: DropboxFileInfo, data: Data) async throws {
        guard let sessionId = file.sessionId else { throw  APIError.errorOccured}
        let cursor = Files.UploadSessionCursor(sessionId: sessionId, offset: UInt64(file.offset))
        debugLog("Appending data to upload session for file: \(file.fileName), offset: \(file.offset)")
        let request = client.files.uploadSessionAppendV2(cursor: cursor, input: data)
        addRequest(file: file, request: request)
        let _ = try await request.response()
        removeRequest(file: file)
        file.offset += Int64(data.count)
    }
    
    private func finishUploadSession(client: DropboxClient, file: DropboxFileInfo, folderName: String, data: Data) async throws {
        guard let sessionId = file.sessionId else { throw  APIError.errorOccured}
        let cursor = Files.UploadSessionCursor(sessionId: sessionId, offset: UInt64(file.offset))
        let commitInfo = Files.CommitInfo(path: folderName.preffixedSlash().slash() + file.fileName, mode: .add, autorename: false, mute: false)
        let request =  client.files.uploadSessionFinish(cursor: cursor, commit: commitInfo, input: data)
        addRequest(file: file, request: request)
        let _ = try await request.response()
        removeRequest(file: file)
        file.offset += Int64(data.count)
        debugLog("Finished upload session for file: \(file.fileName)")
    }
    
    private func handleUploadError(_ error: Error, file: DropboxFileInfo) -> APIError? {
        
        if let callError = error as? UploadSessionAppendError {
            debugLog(callError)
          
            switch callError {
            case .routeError(let boxedLookupError, _, _, _):
                let lookupError = boxedLookupError.unboxed
                switch lookupError {
                case .incorrectOffset(let incorrectOffsetError):
                    let correctOffset = incorrectOffsetError.correctOffset
                    debugLog("Received incorrect_offset error. Adjusting offset from \(file.offset) to \(correctOffset).")
                    file.offset = Int64(correctOffset)
                    return nil
                case .notFound:
                    debugLog("Upload session not found. Starting a new session.")
                    file.sessionId = nil
                    return nil
                default:
                    debugLog("Upload session error: \(lookupError)")
                    return APIError.dropboxApiError(callError)
                }
            default:
                debugLog("Error during upload: \(callError)")
                return APIError.dropboxApiError(callError)
            }
        } else {
            
            
            debugLog("Error is not a CallError<Files.UploadSessionAppendError>")
            return APIError.dropboxApiError(error)
        }
    }
    
    func pauseUpload() {
        isCancelled = true
        
        uploadRequests.forEach { request in
            request.value.forEach({($0 as? UploadSessionStart)?.cancel()})
            request.value.forEach({($0 as? UploadSessionAppend)?.cancel()})
            request.value.forEach({($0 as? UploadSessionFinish)?.cancel()})
        }
        
        uploadRequests.removeAll()
    }
    
    func ensureSignedIn() async throws {
        if let client = DropboxClientsManager.authorizedClient {
            self.client = client
        } else {
            signOut()
            try await handleSignIn()
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
        return isAuthError(error as? UploadError) ||
        isAuthError(error as? CreateFolderError) ||
        isAuthError(error as? UploadSessionStartError) ||
        isAuthError(error as? UploadSessionFinishError) ||
        isAuthError(error as? UploadSessionAppendError)
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
