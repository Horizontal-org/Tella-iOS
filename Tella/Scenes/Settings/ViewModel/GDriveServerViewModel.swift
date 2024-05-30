//
//  GDriveServerViewModel.swift
//  Tella
//
//  Created by gus valbuena on 5/22/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class GDriveServerViewModel: ObservableObject {
    private let gDriveRepository: GDriveRepositoryProtocol

    @Published var sharedDrives: [SharedDrive] = []

    init(repository: GDriveRepositoryProtocol = GDriveRepository.shared) {
        self.gDriveRepository = repository
        restorePreviousSignIn()
    }

    func restorePreviousSignIn() {
        gDriveRepository.restorePreviousSignIn {
            self.getSharedDrives()
        }
    }

    func getSharedDrives() {
        gDriveRepository.getSharedDrives() { [weak self] result in
            switch result {
            case .success(let drives):
                self?.sharedDrives = drives
            case .failure(let error):
                print("Error fetching drives: \(error.localizedDescription)")
            }
        }
    }
}
