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

protocol GDriveRepositoryProtocol {
    func handleSignIn(completion: @escaping (Result<Void, Error>) -> Void)
    func restorePreviousSignIn(completion: (() -> Void)?)
    func handleUrl(url: URL)
    func getSharedDrives(completion: @escaping (Result<[SharedDrive], Error>) -> Void)
}

class GDriveRepository: GDriveRepositoryProtocol  {
    static let shared = GDriveRepository()
    
    private var googleUser: GIDGoogleUser?
    
    private var rootViewController: UIViewController? {
        return UIApplication.shared.windows.first?.rootViewController
    }
    
    func handleSignIn(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let rootViewController = self.rootViewController else {
            print("There is no root view controller!")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                completion(.failure(error))
                return
            } else {
                completion(.success(()))
            }
        }
    }
    
    func restorePreviousSignIn(completion: (() -> Void)? = nil) {
        guard let rootViewController = self.rootViewController else {
            print("There is no root view controller!")
            return
        }
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            user?.addScopes([GoogleAuthScopes.gDriveScopes], presenting: rootViewController)
            
            self.googleUser = user
            completion?()
        }
    }
    
    func handleUrl(url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
    
    func getSharedDrives(completion: @escaping (Result<[SharedDrive], Error>) -> Void) {
        guard let user = self.googleUser else { return }
        let driveService = GTLRDriveService()
        driveService.authorizer = user.fetcherAuthorizer
        
        let query = GTLRDriveQuery_DrivesList.query()
        
        driveService.executeQuery(query) { ticket, response, error in
            if let error = error {
                print("Error fetching drives: \(error.localizedDescription)")
            }

            guard let driveList = response as? GTLRDrive_DriveList, let drives = driveList.drives else {
                return
            }
            
            let sharedDrives = drives.map { drive in
                SharedDrive(id: drive.identifier ?? "", name: drive.name ?? "", kind: drive.kind ?? "")
            }

            completion(.success(sharedDrives))
        }
    }
}
