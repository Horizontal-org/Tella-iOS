//
//  GDriveRepository.swift
//  Tella
//
//  Created by gus valbuena on 5/28/24.
//  Copyright © 2024 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST
import Combine

struct FileUploadDetails {
    let fileURL: URL
    let fileId: String
    let mimeType: String
    let folderId: String
}
protocol GDriveRepositoryProtocol {
    func handleSignIn() async throws
    func handleUrl(url: URL)
    func createDriveFolder(folderName: String, parentId: String?, description: String?) -> AnyPublisher<String, APIError>
    func uploadFile(fileUploadDetails: FileUploadDetails) -> AnyPublisher<UploadProgressInfo, APIError>
    func pauseAllUploads()
    func resumeAllUploads()
    func signOut()
}

class GDriveRepository: GDriveRepositoryProtocol  {
    private var googleUser: GIDGoogleUser?
    private var uploadTasks: [String: GTLRServiceTicket] = [:]
    private var isCancelled = false
    private let networkMonitor: NetworkMonitor
    var subscribers : Set<AnyCancellable> = []
    private let networkStatusSubject = PassthroughSubject<Bool, Never>()
    
    init(networkMonitor: NetworkMonitor = .shared) {
        self.networkMonitor = networkMonitor
        
        setupNetworkMonitor()
    }
    
    private func setupNetworkMonitor() {
        networkMonitor.connectionDidChange.sink(receiveValue: { isConnected in
            self.networkStatusSubject.send(isConnected)
            if(!isConnected) {
                self.pauseAllUploads()
            }
        }).store(in: &subscribers)
    }
    private var rootViewController: UIViewController? {
        return UIApplication.getTopViewController()
    }
    
    private func ensureSignedIn() async throws {
        if self.googleUser == nil {
            try await restorePreviousSignIn()
        }
    }
    
    private func hasRequiredScopes(_ user: GIDGoogleUser) -> Bool {
        let requiredScopes = [GoogleAuthConstants.gDriveScopesFile]
        guard let grantedScopes = user.grantedScopes else {
            return false
        }
        return requiredScopes.allSatisfy { scope in
            grantedScopes.contains(scope)
        }
    }
    
    private func ensureScopes(
        for user: GIDGoogleUser,
        presenting rootViewController: UIViewController,
        continuation: CheckedContinuation<Void, Error>
    ) {
        if hasRequiredScopes(user) {
            self.googleUser = user
            continuation.resume(returning: ())
            return
        }
        
        user.addScopes(
            [GoogleAuthConstants.gDriveScopesFile],
            presenting: rootViewController
        ) { [weak self] signInResult, error in
            guard let self else {
                continuation.resume(throwing: APIError.unexpectedResponse)
                return
            }
            
            if let error = error {
                if let nsError = error as NSError?,
                   nsError.code == GoggleDriveErrorCodes.scopesAlreadyGranted.rawValue {
                    self.googleUser = user
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: APIError.driveApiError(error))
                }
                return
            }
            
            self.googleUser = signInResult?.user ?? user
            continuation.resume(returning: ())
        }
    }
    
    func handleSignIn() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    continuation.resume(throwing: APIError.unexpectedResponse)
                    return
                }
                guard let rootViewController = self.rootViewController else {
                    continuation.resume(throwing: APIError.unexpectedResponse)
                    return
                }
                
                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] signInResult, error in
                    guard let self else {
                        continuation.resume(throwing: APIError.unexpectedResponse)
                        return
                    }
                    
                    if let error = error {
                        continuation.resume(throwing: APIError.driveApiError(error))
                        return
                    }
                    
                    guard let user = signInResult?.user else {
                        continuation.resume(throwing: APIError.unexpectedResponse)
                        return
                    }
                    
                    self.ensureScopes(for: user, presenting: rootViewController, continuation: continuation)
                }
            }
        }
    }
    
    private func restorePreviousSignIn() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    continuation.resume(throwing: APIError.unexpectedResponse)
                    return
                }
                guard let rootViewController = self.rootViewController else {
                    continuation.resume(throwing: APIError.unexpectedResponse)
                    return
                }
                
                GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                    guard let self else {
                        continuation.resume(throwing: APIError.unexpectedResponse)
                        return
                    }
                    
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let user = user else {
                        continuation.resume(throwing: APIError.unexpectedResponse)
                        return
                    }
                    
                    self.ensureScopes(for: user, presenting: rootViewController, continuation: continuation)
                }
            }
        }
    }
    
    func handleUrl(url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
    
    func createDriveFolder(
        folderName: String,
        parentId: String? = nil,
        description: String?
    ) -> AnyPublisher<String, APIError> {
        Deferred {
            Future { promise in
                guard self.networkMonitor.isConnected else {
                    promise(.failure(.noInternetConnection))
                    return
                }
                Task {
                    do {
                        try await self.ensureSignedIn()
                        self.performCreateDriveFolder(
                            folderName: folderName,
                            parentId: parentId,
                            description: description,
                            promise: promise)
                    } catch {
                        promise(.failure(.driveApiError(error)))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func performCreateDriveFolder(
        folderName: String,
        parentId: String?,
        description: String?,
        promise: @escaping (Result<String, APIError>) -> Void
    ) {
        guard let user = googleUser else {
            promise(.failure(APIError.noToken))
            return
        }
        
        let driveService = GTLRDriveService()
        driveService.authorizer = user.fetcherAuthorizer
        
        let folder = GTLRDrive_File()
        folder.name = folderName
        folder.mimeType = GoogleAuthConstants.gDriveFolderMimeType
        
        if let parentID = parentId {
            folder.parents = [parentID]
        }
        
        if let description = description {
            folder.descriptionProperty = description
        }
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        
        driveService.executeQuery(query) { (ticket, file, error) in
            if let error = error {
                debugLog("Error creating folder: \(error.localizedDescription)")
                promise(.failure(.driveApiError(error)))
                return
            }
            
            guard let createdFile = file as? GTLRDrive_File else {
                promise(.failure(APIError.unexpectedResponse))
                return
            }
            
            promise(.success(createdFile.identifier ?? ""))
        }
    }
    
    func uploadFile(
        fileUploadDetails: FileUploadDetails
    ) -> AnyPublisher<UploadProgressInfo, APIError> {
        return Deferred {
            Future { promise in
                guard self.networkMonitor.isConnected else {
                    promise(.failure(.noInternetConnection))
                    return
                }
                Task { @MainActor in
                    do {
                        try await self.ensureSignedIn()
                        self.performUploadFile(
                            fileUploadDetails: fileUploadDetails,
                            promise: promise
                        )
                        
                        self.networkStatusSubject
                            .filter { !$0 }
                            .first()
                            .sink { _ in
                                promise(.failure(.noInternetConnection))
                            }
                            .store(in: &self.subscribers)
                    } catch {
                        promise(.failure(.driveApiError(error)))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func performUploadFile(
        fileUploadDetails: FileUploadDetails,
        promise: @escaping (Result<UploadProgressInfo, APIError>) -> Void
    ) {
        Task {
            do {
                if isCancelled {
                    return
                }
                
                guard self.networkMonitor.isConnected else {
                    promise(.failure(.noInternetConnection))
                    return
                }
                
                guard let user = self.googleUser else {
                    promise(.failure(.noToken))
                    return
                }
                
                let driveService = GTLRDriveService()
                driveService.authorizer = user.fetcherAuthorizer
                
                let fileURL = fileUploadDetails.fileURL
                let fileId = fileUploadDetails.fileId
                let folderId = fileUploadDetails.folderId
                
                let fileName = fileURL.lastPathComponent
                let totalSize = UInt64((try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
                let uploadProgressInfo = UploadProgressInfo(bytesSent: Int(totalSize), fileId: fileId, status: .notSubmitted)
                
                let fileExists = try await checkFileExists(fileName: fileName, folderId: folderId, driveService: driveService)
                
                if fileExists {
                    // File already exists, mark as uploaded
                    uploadProgressInfo.bytesSent = Int(totalSize)
                    uploadProgressInfo.status = .submitted
                    promise(.success(uploadProgressInfo))
                } else {
                    // File doesn't exist, proceed with upload
                    let result = try await self.uploadNewFile(fileUploadDetails: fileUploadDetails, driveService: driveService, uploadProgressInfo: uploadProgressInfo)
                    
                    promise(.success(result))
                }
            } catch {
                promise(.failure(.driveApiError(error)))
            }
        }
    }
    
    @MainActor
    private func uploadNewFile(
        fileUploadDetails: FileUploadDetails,
        driveService: GTLRDriveService,
        uploadProgressInfo: UploadProgressInfo
    ) async throws -> UploadProgressInfo {
        let fileURL = fileUploadDetails.fileURL
        let mimeType = fileUploadDetails.mimeType
        let fileId = fileUploadDetails.fileId
        let folderId = fileUploadDetails.folderId
        
        let file = GTLRDrive_File()
        file.name = fileURL.lastPathComponent
        file.mimeType = mimeType
        file.parents = [folderId]
        
        let uploadParameters = GTLRUploadParameters(fileURL: fileURL, mimeType: mimeType)
        uploadParameters.shouldUploadWithSingleRequest = false
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)
        
        return try await withCheckedThrowingContinuation { continuation in
            let ticket = driveService.executeQuery(query) { [weak self] (ticket, file, error) in
                guard let self = self else {
                    continuation.resume(throwing: APIError.unexpectedResponse)
                    return
                }
                
                Task { @MainActor in
                    defer {
                        self.uploadTasks.removeValue(forKey: fileId)
                    }
                    
                    do {
                        if self.isCancelled {
                            uploadProgressInfo.status = .notSubmitted
                            return
                        }
                        
                        if let error = error {
                            throw APIError.driveApiError(error)
                        }
                        
                        guard file is GTLRDrive_File else {
                            throw APIError.unexpectedResponse
                        }
                        
                        uploadProgressInfo.bytesSent = Int(uploadProgressInfo.bytesSent!)
                        uploadProgressInfo.status = .submitted
                        continuation.resume(returning: uploadProgressInfo)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            self.uploadTasks[fileId] = ticket
        }
    }
    
    private func checkFileExists(fileName: String, folderId: String, driveService: GTLRDriveService) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            let query = GTLRDriveQuery_FilesList.query()
            query.q = "name = '\(fileName)' and '\(folderId)' in parents and trashed = false"
            query.fields = "files(id, name)"
            
            driveService.executeQuery(query) { (_, response, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let fileList = response as? GTLRDrive_FileList, let files = fileList.files, !files.isEmpty {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    func pauseAllUploads() {
        isCancelled = true
        uploadTasks.forEach { $0.value.cancel() }
        uploadTasks.removeAll()
    }
    
    func resumeAllUploads() {
        isCancelled = false
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    private func handleSubmissionError(uploadProgressInfo: UploadProgressInfo, promise: @escaping (Result<UploadProgressInfo, APIError>) -> Void) {
        uploadProgressInfo.status = .submissionError
        if !networkMonitor.isConnected {
            uploadProgressInfo.error = APIError.noInternetConnection
            promise(.failure(.noInternetConnection))
            return
        }
        uploadProgressInfo.error = APIError.unexpectedResponse
        promise(.failure(.unexpectedResponse))
    }
}

struct UploadProgressWithFolderId {
    let folderId: String
    let progressInfo: UploadProgressInfo
}
