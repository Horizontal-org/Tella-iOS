//
//  GDriveAuthViewModel.swift
//  Tella
//
//  Created by gus valbuena on 5/22/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class GDriveAuthViewModel: ObservableObject {
    private let gDriveRepository: GDriveRepositoryProtocol

    init(repository: GDriveRepositoryProtocol = GDriveRepository.shared) {
        self.gDriveRepository = repository
    }

    func handleSignIn(completion: @escaping (Result<Void, Error>) -> Void) {
        gDriveRepository.handleSignIn { result in
            completion(result)
        }
    }

    func restorePreviousSignIn() {
        gDriveRepository.restorePreviousSignIn() { _ in
            
        }
    }

    func handleUrl(url: URL) {
        gDriveRepository.handleUrl(url: url)
    }
}
