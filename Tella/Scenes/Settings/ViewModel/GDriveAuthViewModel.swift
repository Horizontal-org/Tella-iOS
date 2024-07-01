//
//  GDriveAuthViewModel.swift
//  Tella
//
//  Created by gus valbuena on 5/22/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class GDriveAuthViewModel: ObservableObject {
    private let gDriveRepository: GDriveRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(repository: GDriveRepositoryProtocol = GDriveRepository.shared) {
        self.gDriveRepository = repository
    }

    func handleSignIn(completion: @escaping () -> Void) {
        Task {
            do {
                try await gDriveRepository.handleSignIn()
                DispatchQueue.main.async {
                    completion()
                }
            } catch let error {
                DispatchQueue.main.async {
                    Toast.displayToast(message: error.localizedDescription)
                }
            }
        }
    }

    func handleUrl(url: URL) {
        gDriveRepository.handleUrl(url: url)
    }
}
