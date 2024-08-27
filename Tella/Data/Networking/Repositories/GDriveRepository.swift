//
//  GDriveRepository.swift
//  Tella
//
//  Created by gus valbuena on 5/28/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
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
    func restorePreviousSignIn() async throws
    func handleUrl(url: URL)
    func getSharedDrives() -> AnyPublisher<[SharedDrive], APIError>
    func createDriveFolder(folderName: String, parentId: String?, description: String?) -> AnyPublisher<String, APIError>
    func uploadFile(fileUploadDetails: FileUploadDetails) -> AnyPublisher<UploadProgressInfo, APIError>
    func pauseAllUploads()
    func resumeAllUploads()
    func signOut() -> Void
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
    
    func handleSignIn() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async {
                guard let rootViewController = self.rootViewController else {
                    return
                }
                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        signInResult?.user.addScopes([GoogleAuthConstants.gDriveScopes], presenting: rootViewController)
                        self.googleUser = signInResult?.user
                        continuation.resume(returning: ())
                    }
                }
            }
        }
    }
    
    func restorePreviousSignIn() async throws {
        try await withCheckedThrowingContinuation{ (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async {
                guard let rootViewController = self.rootViewController else {
                    return
                }
                
                GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    user?.addScopes([GoogleAuthConstants.gDriveScopes], presenting: rootViewController)
                    
                    self.googleUser = user
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    func handleUrl(url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
    
    func getSharedDrives() -> AnyPublisher<[SharedDrive], APIError> {
        Deferred {
            Future { [weak self] promise in
                guard let user = self?.googleUser else {
                    return promise(.failure(APIError.noToken))
                }
                let driveService = GTLRDriveService()
                driveService.authorizer = user.fetcherAuthorizer

                let query = GTLRDriveQuery_DrivesList.query()

                driveService.executeQuery(query) { ticket, response, error in
                    if let error = error {
                        debugLog("Error fetching drives: \(error.localizedDescription)")
                        promise(.failure(.driveApiError(error)))
                    }

                    guard let driveList = response as? GTLRDrive_DriveList,
                        let drives = driveList.drives
                    else {
                        return
                    }

                    let sharedDrives = drives.map { drive in
                        SharedDrive(
                            id: drive.identifier ?? "", name: drive.name ?? "",
                            kind: drive.kind ?? "")
                    }

                    promise(.success(sharedDrives))
                }
            }
        }
        .eraseToAnyPublisher()
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
        query.supportsAllDrives = true
        
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
                let mimeType = fileUploadDetails.mimeType
                let fileId = fileUploadDetails.fileId
                let folderId = fileUploadDetails.folderId
                
                let fileName = fileURL.lastPathComponent
                let totalSize = UInt64((try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
                let uploadProgressInfo = UploadProgressInfo(fileId: fileId, status: .notSubmitted, total: Int(totalSize))
                
                let fileExists = try await checkFileExists(fileName: fileName, folderId: folderId, driveService: driveService)
                
                if fileExists {
                    // File already exists, mark as uploaded
                    uploadProgressInfo.bytesSent = Int(totalSize)
                    uploadProgressInfo.current = Int(totalSize)
                    uploadProgressInfo.status = .uploaded
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
        query.supportsAllDrives = true
        
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
                        
                        uploadProgressInfo.bytesSent = Int(uploadProgressInfo.total!)
                        uploadProgressInfo.current = Int(uploadProgressInfo.total!)
                        uploadProgressInfo.status = .uploaded
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
            query.includeItemsFromAllDrives = true
            query.supportsAllDrives = true
            
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


class GDriveDIContainer : DIContainer {
    
    let gDriveRepository: GDriveRepositoryProtocol
    
    init(gDriveRepository: GDriveRepositoryProtocol = GDriveRepository()) {
        self.gDriveRepository = gDriveRepository
    }
}

class DIContainer {
    
}


struct UploadProgressWithFolderId {
    let folderId: String
    let progressInfo: UploadProgressInfo
}
