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
    @Published var signInState: ViewModelState<String?> = .loaded(nil)
    init(repository: GDriveRepositoryProtocol) {
        self.gDriveRepository = repository
    }

    func handleSignIn(completion: @escaping () -> Void) {
        self.signInState = .loading
        Task { @MainActor in
            do {
                try await gDriveRepository.handleSignIn()
                self.signInState = .loaded(nil)
                completion()
            } catch let error {
                self.signInState = .error(error.localizedDescription)
            }
        }
    }


    func handleUrl(url: URL) {
        gDriveRepository.handleUrl(url: url)
    }
}
