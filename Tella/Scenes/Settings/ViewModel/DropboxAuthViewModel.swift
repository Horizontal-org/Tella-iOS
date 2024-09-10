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
    private let dropboxServerViewModel: DropboxServerViewModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published var signInState: ViewModelState<String?> = .loaded(nil)
    private var authCompletion: (() -> Void)?
    
    init(dropboxRepository: DropboxRepositoryProtocol, dropboxServerViewModel: DropboxServerViewModel) {
        self.dropboxRepository = dropboxRepository
        self.dropboxServerViewModel = dropboxServerViewModel
    }
    
    func handleSignIn(completion: @escaping () -> Void) {
        self.signInState = .loading
        self.authCompletion = completion
        Task { @MainActor in
            do {
                try await dropboxRepository.handleSignIn()
                completion()
            } catch let error as APIError {
                self.signInState = .error(error.errorMessage)
            }
        }
    }
    
    func handleURLRedirect(url: URL) {
        let _ = DropboxClientsManager.handleRedirectURL(url, includeBackgroundClient: false) { [weak self] authResult in
            guard let self = self else { return }
            
            Task { @MainActor in
                    
                switch authResult {
                case .success:
                    self.signInState = .loaded(nil)
                    await self.createServerConnection()
                    self.authCompletion?()
                case .error(_, let description):
                    self.signInState = .error(description ?? "")
                default:
                    self.signInState = .error("unexpected server error") // change this with a proper message
                }
                self.authCompletion = nil
            }
        }
    }
    
    private func createServerConnection() async {
        await MainActor.run {
            self.dropboxServerViewModel.addServer()
        }
    }
}
