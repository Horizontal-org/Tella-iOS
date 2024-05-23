//
//  GDriveAuthViewModel.swift
//  Tella
//
//  Created by gus valbuena on 5/22/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST

class GDriveAuthViewModel: ObservableObject {
    
    func handleSignInButton(completion: @escaping () -> Void) {
      guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
        print("There is no root view controller!")
        return
      }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                print("Error during Google Sign-In: \(error.localizedDescription)")
                return
            } else {
                completion()
            }
      }
    }
    
    func restorePreviousSignIn() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
          print("There is no root view controller!")
          return
        }
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            user?.addScopes(["https://www.googleapis.com/auth/drive"], presenting: rootViewController)
            dump(user)
        }
    }
    
    func handleUrl(url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
}
