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
    private let gDriveRepository: GDriveRepositoryProtocol

    @Published var googleUser: GIDGoogleUser? = nil
    @Published var sharedDrives: [GTLRDrive_Drive] = []

    init(repository: GDriveRepositoryProtocol = GDriveRepository.shared) {
        self.gDriveRepository = repository
        restorePreviousSignIn()
    }

    func restorePreviousSignIn() {
        gDriveRepository.restorePreviousSignIn { [weak self] user in
            self?.googleUser = user
            self?.getSharedDrives()
        }
    }

    func getSharedDrives() {
        gDriveRepository.getSharedDrives(googleUser: googleUser) { [weak self] result in
            switch result {
            case .success(let drives):
                self?.sharedDrives = drives
            case .failure(let error):
                print("Error fetching drives: \(error.localizedDescription)")
            }
        }
    }
}
