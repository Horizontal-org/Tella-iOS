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
    func handleSignInButton(completion: @escaping (Result<Void, Error>) -> Void)
    func restorePreviousSignIn(completion: ((_ user: GIDGoogleUser?) -> Void)?)
    func handleUrl(url: URL)
    func getSharedDrives(googleUser: GIDGoogleUser?, completion: @escaping (Result<[GTLRDrive_Drive], Error>) -> Void)
}

struct GDriveRepository: GDriveRepositoryProtocol  {
    static let shared = GDriveRepository()
    private var rootViewController: UIViewController? {
        return UIApplication.shared.windows.first?.rootViewController
    }
    
    func handleSignInButton(completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    func restorePreviousSignIn(completion: ((_ user: GIDGoogleUser?) -> Void)? = nil) {
        guard let rootViewController = self.rootViewController else {
            print("There is no root view controller!")
            return
        }
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            user?.addScopes(["https://www.googleapis.com/auth/drive"], presenting: rootViewController)
            
            completion?(user)
        }
    }
    
    func handleUrl(url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
    
    func getSharedDrives(googleUser: GIDGoogleUser?, completion: @escaping (Result<[GTLRDrive_Drive], Error>) -> Void) {
        guard let user = googleUser else { return }
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

            completion(.success(drives))
        }
    }
}
