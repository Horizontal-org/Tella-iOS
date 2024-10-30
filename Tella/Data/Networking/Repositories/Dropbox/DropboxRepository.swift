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
    func submit(report: DropboxReportToSend) -> AnyPublisher<DropboxUploadResponse, APIError>
    func pauseUpload()
}

class DropboxRepository: DropboxRepositoryProtocol {
    
    private var client: DropboxClient?
    private var shouldPause = false
    private let networkMonitor: NetworkMonitor
    private var subscribers: Set<AnyCancellable> = []
    private let networkStatusSubject = PassthroughSubject<Bool, Never>()
    private var UploadResponseSubject = CurrentValueSubject<DropboxUploadResponse, APIError>(.initial)
    private var uploadTask: Task<Void, Error>?
    private let descriptionFolderName = "description.txt"
    private let chunkSize: Int64 = 1024 * 1024
    
    init(networkMonitor: NetworkMonitor = .shared) {
        self.networkMonitor = networkMonitor
        setupNetworkMonitor()
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
    
    func pauseUpload() {
        shouldPause = true
        uploadTask?.cancel()
    }
    
    func ensureSignedIn() async throws {
        if let client = DropboxClientsManager.authorizedClient {
            self.client = client
        } else {
            signOut()
        }
    }
    
    func signOut() {
        DropboxClientsManager.unlinkClients()
        client = nil
    }
    
    func submit(report: DropboxReportToSend) -> AnyPublisher<DropboxUploadResponse, APIError> {
        let subject = CurrentValueSubject<DropboxUploadResponse, APIError>(.initial)
        
        
        shouldPause = false
        
        uploadTask = Task {
            do {
                
                try checkInternetConnection()
                
                try await ensureSignedIn()
                
                switch report.remoteReportStatus {
                    
                case .initial :
                    try await handleInitialStatus(report: report, subject: subject)
                    
                case .created:
                    try await handleCreatedStatus(report: report, subject: subject)
                    
                default:
                    break
                }
                
                if report.files.isEmpty {
                    subject.send(completion:.finished)
                    return
                }
                
                guard !shouldPause else { return }
                
                try checkInternetConnection()
                
                uploadFiles(report: report, subject: subject)
                
                monitorNetworkConnection()
                
                UploadResponseSubject = subject
                
            } catch let apiError as APIError {
                subject.send(completion: .failure(apiError))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    private func handleInitialStatus(report: DropboxReportToSend,
                                     subject: CurrentValueSubject<DropboxUploadResponse, APIError>) async throws {
        
        guard !shouldPause else { return }
        
        let folderName = try await createFolder(name: report.name)
        subject.send(.folderCreated(folderName: folderName))
        
        guard !shouldPause else { return }
        
        report.name = folderName
        
        try await uploadDescriptionFile(report: report)
        subject.send(.descriptionSent)
        
    }
    
    private func handleCreatedStatus(report: DropboxReportToSend,
                                     subject: CurrentValueSubject<DropboxUploadResponse, APIError>) async throws {
        
        guard !shouldPause else { return }
        
        try await uploadDescriptionFile(report: report)
        subject.send(.descriptionSent)
    }
    
    private func createFolder(name: String) async throws -> String {
        
        try checkInternetConnection()
        
        guard let client = self.client else {
            throw APIError.noToken
        }
        
        let folderPath = name.preffixedSlash().trimmed()
        
        return   try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            client.files.createFolderV2(path: folderPath, autorename: true).response { response, error in
                if let error = error {
                    let dropboxError = error.getError()
                    let apiError = APIError.dropboxApiError(dropboxError)
                    continuation.resume(throwing:apiError)
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
                        let dropboxError = error.getError()
                        let apiError = APIError.dropboxApiError(dropboxError)
                        continuation.resume(throwing:apiError)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
        }
    }
    
    private func uploadFiles(report: DropboxReportToSend, subject: CurrentValueSubject<DropboxUploadResponse, APIError>) {
        
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
                                    folderName: String ) -> CurrentValueSubject<UploadProgressInfo,APIError>  {
        
        let progressInfo = UploadProgressInfo(fileId: file.fileId, status: FileStatus.partialSubmitted)
        
        let subject = CurrentValueSubject<UploadProgressInfo, APIError>(progressInfo)
        
        Task {
            
            try checkInternetConnection()
            
            let fileSize = file.totalBytes
            
            let fileHandle = try FileHandle(forReadingFrom: file.url)
            defer { try? fileHandle.close() }
            
            let chunkSize = fileSize < self.chunkSize ? fileSize : self.chunkSize
            
            while file.offset < fileSize {
                
                do {
                    
                    if shouldPause {
                        return
                    }
                    
                    let data = try fileHandle.readChunk(from: file.offset, chunkSize: chunkSize, fileSize: fileSize)
                    let remainingBytes = fileSize - file.offset
                    
                    
                    try await processChunkUpload(file: file,
                                                 folderName: folderName,
                                                 data: data,
                                                 remainingBytes: remainingBytes,
                                                 progressInfo: progressInfo,
                                                 subject: subject,chunkSize: chunkSize)
                }  catch {
                    handleUploadError(error: error,
                                      file: file,
                                      progressInfo: progressInfo,
                                      subject: subject)
                }
            }
            
            if file.offset >= fileSize {
                progressInfo.status = .uploaded
                progressInfo.finishUploading = true
                subject.send(progressInfo)
            }
        }
        
        return subject
    }
    
    private func processChunkUpload(file: DropboxFileInfo,
                                    folderName: String,
                                    data: Data,
                                    remainingBytes: Int64,
                                    progressInfo: UploadProgressInfo,
                                    subject: CurrentValueSubject<UploadProgressInfo, APIError>,
                                    chunkSize:Int64) async throws {
        
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
        
        file.offset += Int64(data.count)
        
        if remainingBytes > chunkSize {
            progressInfo.sessionId = file.sessionId
            progressInfo.status = .partialSubmitted
            progressInfo.bytesSent = Int(file.offset)
            subject.send(progressInfo)
        }
    }
    
    private func handleUploadError(error:Error,
                                   file: DropboxFileInfo,
                                   progressInfo: UploadProgressInfo,
                                   subject: CurrentValueSubject<UploadProgressInfo, APIError>) {
        let dropboxError = error.getError()
        let apiError = APIError.dropboxApiError(dropboxError)
        
        switch dropboxError {
            
        case .incorrectOffset(let newOffset):
            file.offset = Int64(newOffset)
            
        case .sessionNotFound:
            file.sessionId = nil
            
        case .insufficientSpace, .noToken:
            progressInfo.error = apiError
            progressInfo.status = .submissionError
            progressInfo.finishUploading = true
            subject.send(completion: .failure(apiError))
            return
            
        default:
            progressInfo.error = apiError
            progressInfo.status = .submissionError
            progressInfo.finishUploading = true
            subject.send(progressInfo)
            return
        }
    }
    
    private func startUploadSession(file: DropboxFileInfo,client: DropboxClient, data: Data) async throws {
        let request = client.files.uploadSessionStart(input: data)
        let response = try await request.response()
        file.sessionId = response.sessionId
    }
    
    private func appendToUploadSession(client: DropboxClient, file: DropboxFileInfo, data: Data) async throws {
        debugLog("Appending data to upload session for file: \(file.fileName), offset: \(file.offset)")
        
        guard let sessionId = file.sessionId else { throw  APIError.errorOccured}
        
        let cursor = Files.UploadSessionCursor(sessionId: sessionId,
                                               offset: UInt64(file.offset))
        let request = client.files.uploadSessionAppendV2(cursor: cursor,
                                                         input: data)
        let _ = try await request.response()
    }
    
    private func finishUploadSession(client: DropboxClient, file: DropboxFileInfo, folderName: String, data: Data) async throws {
        guard let sessionId = file.sessionId else { throw  APIError.errorOccured}
        
        let offset = file.offset == 0 ? Int64(data.count) : file.offset
        
        let cursor = Files.UploadSessionCursor(sessionId: sessionId,
                                               offset: UInt64(offset))
        
        let path = folderName.preffixedSlash().slash() + file.fileName
        let commitInfo = Files.CommitInfo(path: path,
                                          mode: .add,
                                          autorename: false,
                                          mute: false)
        
        let request =  client.files.uploadSessionFinish(cursor: cursor,
                                                        commit: commitInfo,
                                                        input: data)
        let _ = try await request.response()
        
        debugLog("Finished upload session for file: \(file.fileName)")
    }
    
    private func setupNetworkMonitor() {
        networkMonitor.connectionDidChange.sink { isConnected in
            self.networkStatusSubject.send(isConnected)
            if !isConnected {
                self.UploadResponseSubject.send(completion: .failure(.noInternetConnection))
            }
        }.store(in: &subscribers)
    }
    
    private func handleNetworkLoss() {
        pauseUpload()
        UploadResponseSubject.send(completion: .failure(.noInternetConnection))
    }
    
    private func monitorNetworkConnection() {
        self.networkStatusSubject
            .filter { !$0 }
            .first()
            .sink { _ in
                self.handleNetworkLoss()
            }
            .store(in: &self.subscribers)
    }
    
    private func checkInternetConnection() throws {
        guard self.networkMonitor.isConnected else {
            throw APIError.noInternetConnection
        }
    }
}

extension String {
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
