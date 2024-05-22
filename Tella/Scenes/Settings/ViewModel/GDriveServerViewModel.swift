//
//  GDriveServerViewModel.swift
//  Tella
//
//  Created by gus valbuena on 5/22/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST

class GDriveServerViewModel: ObservableObject {
    var googleUser:GIDGoogleUser? = nil
    @Published var sharedDrives: [GTLRDrive_Drive] = []
    
    init() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [self] user, error in
            self.googleUser = user
            
            getSharedDrives()
        }
    }
    
    func getSharedDrives() {
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

            self.sharedDrives = drives
        }
    }
}
