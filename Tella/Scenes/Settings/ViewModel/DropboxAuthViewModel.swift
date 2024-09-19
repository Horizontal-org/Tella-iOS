//
//  DropboxAuthViewModel.swift
//  Tella
//
//  Created by gus valbuena on 9/3/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
import SwiftyDropbox

class DropboxAuthViewModel: ObservableObject {
    private let dropboxRepository: DropboxRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var signInState: ViewModelState<String?> = .loaded(nil)
    init(dropboxRepository: DropboxRepositoryProtocol) {
        self.dropboxRepository = dropboxRepository
    }
    
    func handleSignIn() {
        self.signInState = .loading
        Task { @MainActor in
            do {
                try await dropboxRepository.handleSignIn()
                self.signInState = .loaded(nil)
            } catch let error as APIError {
                self.signInState = .error(error.errorMessage)
            }
        }
    }
    
    func handleURLRedirect(url: URL) {
        let _ = DropboxClientsManager.handleRedirectURL(url, includeBackgroundClient: false) { authResult in
            // Handle auth result
            dump(authResult)
        }
    }
}
