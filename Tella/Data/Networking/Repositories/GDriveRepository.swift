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

protocol GDriveRepositoryProtocol {
    func handleSignIn() async throws
    func restorePreviousSignIn() async throws
    func handleUrl(url: URL)
    func getSharedDrives() -> AnyPublisher<[SharedDrive], Error>
    func createDriveFolder(folderName: String, parentId: String?, description: String?) -> AnyPublisher<String, Error>
    func uploadFile(fileURL: URL, fileId: String, mimeType: String, folderId: String) -> AnyPublisher<UploadProgressInfo, Error>
    func pauseAllUploads()
    func resumeAllUploads()
    func signOut() -> Void
}

class GDriveRepository: GDriveRepositoryProtocol  {
    private var googleUser: GIDGoogleUser?
    private var uploadTasks: [String: GTLRServiceTicket] = [:]
    private let uploadQueue = DispatchQueue(label: "com.tella.gdriveupload", attributes: .concurrent)
    private let uploadLock = NSLock()
    private(set) var isUploading = false
    
    private var rootViewController: UIViewController? {
        return UIApplication.shared.windows.first?.rootViewController
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
    
    func getSharedDrives() -> AnyPublisher<[SharedDrive], Error> {
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
                        print("Error fetching drives: \(error.localizedDescription)")
                        promise(.failure(error))
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
    ) -> AnyPublisher<String, Error> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        try await self.ensureSignedIn()
                        self.performCreateDriveFolder(
                            folderName: folderName,
                            parentId: parentId,
                            description: description,
                            promise: promise)
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func performCreateDriveFolder(
        folderName: String,
        parentId: String?,
        description: String?,
        promise: @escaping (Result<String, Error>) -> Void
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
                print("Error creating folder: \(error.localizedDescription)")
                promise(.failure(error))
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
            fileURL: URL,
            fileId: String,
            mimeType: String,
            folderId: String
    ) -> AnyPublisher<UploadProgressInfo, Error> {
        return Deferred {
            Future<UploadProgressInfo, Error> { [weak self] promise in
                guard let self = self else {
                    promise(.failure(APIError.unexpectedResponse))
                    return
                }
                
                self.uploadQueue.async {
                    self.uploadLock.lock()
                    defer { self.uploadLock.unlock() }
                    
                    guard self.isUploading else {
                        promise(.failure(APIError.unexpectedResponse))
                        return
                    }
                    
                    guard let user = self.googleUser else {
                        promise(.failure(APIError.noToken))
                        return
                    }
                    
                    let driveService = GTLRDriveService()
                    driveService.authorizer = user.fetcherAuthorizer
                    
                    let file = GTLRDrive_File()
                    file.name = fileURL.lastPathComponent
                    file.mimeType = mimeType
                    file.parents = [folderId]
                    
                    let uploadParameters = GTLRUploadParameters(fileURL: fileURL, mimeType: mimeType)
                    uploadParameters.shouldUploadWithSingleRequest = false
                    
                    let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)
                    query.supportsAllDrives = true
                    
                    let totalSize = UInt64((try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
                    var uploadProgressInfo = UploadProgressInfo(fileId: fileId, status: .notSubmitted, total: Int(totalSize))
                    
                    let ticket = driveService.executeQuery(query) { [weak self] (ticket, file, error) in
                        guard let self = self else { return }
                        
                        self.uploadLock.lock()
                        defer {
                            self.uploadLock.unlock()
                            self.uploadTasks.removeValue(forKey: fileId)
                        }
                        
                        if !self.isUploading {
                            uploadProgressInfo.status = .notSubmitted
                            promise(.success(uploadProgressInfo))
                            return
                        }
                        
                        if let error = error {
                            uploadProgressInfo.error = APIError.unexpectedResponse
                            uploadProgressInfo.status = .submissionError
                            promise(.failure(error))
                            return
                        }
                        
                        guard let uploadedFile = file as? GTLRDrive_File else {
                            let error = APIError.unexpectedResponse
                            uploadProgressInfo.error = error
                            uploadProgressInfo.status = .submissionError
                            promise(.failure(error))
                            return
                        }
                        
                        uploadProgressInfo.bytesSent = Int(totalSize)
                        uploadProgressInfo.current = Int(totalSize)
                        uploadProgressInfo.status = .uploaded
                        promise(.success(uploadProgressInfo))
                    }
                    
                    
                    self.uploadTasks[fileId] = ticket
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func pauseAllUploads() {
        uploadLock.lock()
        defer { uploadLock.unlock() }
        
        isUploading = false
        uploadTasks.forEach { $0.value.cancel() }
        uploadTasks.removeAll()
    }

    func resumeAllUploads() {
        uploadLock.lock()
        defer { uploadLock.unlock() }
        
        isUploading = true
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
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
