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
    func createDriveFolder(folderName: String) -> AnyPublisher<String, Error>
    func signOut() -> Void
}

class GDriveRepository: GDriveRepositoryProtocol  {
    static let shared = GDriveRepository()
    
    private var googleUser: GIDGoogleUser?
    
    private var rootViewController: UIViewController? {
        return UIApplication.shared.windows.first?.rootViewController
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
                    user?.addScopes([GoogleAuthScopes.gDriveScopes], presenting: rootViewController)
                    
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
                guard let user = self?.googleUser else { return }
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
        folderName: String
    ) -> AnyPublisher<String, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let user = self?.googleUser else {
                    print("User not authenticated")
                    return
                }
                
                let driveService = GTLRDriveService()
                driveService.authorizer = user.fetcherAuthorizer
                
                let folder = GTLRDrive_File()
                folder.name = folderName
                folder.mimeType = "application/vnd.google-apps.folder"
                
                let query = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
                
                driveService.executeQuery(query) { (ticket, file, error) in
                    if let error = error {
                        print("Error creating folder: \(error.localizedDescription)")
                        promise(.failure(error))
                        return
                    }
                    
                    guard let createdFile = file as? GTLRDrive_File else {
                        return
                    }
                    
                    promise(.success(createdFile.identifier ?? ""))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
}
