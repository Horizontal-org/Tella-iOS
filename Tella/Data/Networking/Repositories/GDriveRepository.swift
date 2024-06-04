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
    func handleSignIn() -> AnyPublisher<Bool, Error>
    func restorePreviousSignIn() -> AnyPublisher<Bool, Error>
    func handleUrl(url: URL)
    func getSharedDrives() -> AnyPublisher<[SharedDrive], Error>
}

class GDriveRepository: GDriveRepositoryProtocol  {
    static let shared = GDriveRepository()
    
    private var googleUser: GIDGoogleUser?
    
    private var rootViewController: UIViewController? {
        return UIApplication.shared.windows.first?.rootViewController
    }
    
    func handleSignIn() -> AnyPublisher<Bool, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let rootViewController = self?.rootViewController else {
                    print("There is no root view controller!")
                    return
                }
                
                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    } else {
                        promise(.success(true))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func restorePreviousSignIn() -> AnyPublisher<Bool, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let rootViewController = self?.rootViewController else {
                    print("There is no root view controller!")
                    return
                }
                
                GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    user?.addScopes([GoogleAuthScopes.gDriveScopes], presenting: rootViewController)
                    
                    self?.googleUser = user
                    promise(.success(true))
                }
                
            }
        }.eraseToAnyPublisher()
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
}
