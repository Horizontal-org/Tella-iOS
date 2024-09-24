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

class DropboxServerViewModel: ObservableObject {
    var mainAppModel: MainAppModel
    private let dropboxRepository: DropboxRepositoryProtocol
    
    @Published var signInState: ViewModelState<Bool> = .loaded(false)
    
    init(dropboxRepository: DropboxRepositoryProtocol, mainAppModel: MainAppModel) {
        self.dropboxRepository = dropboxRepository
        self.mainAppModel = mainAppModel
    }
    
    func handleSignIn() {
        self.signInState = .loading
        Task { @MainActor in
            do {
                try await dropboxRepository.handleSignIn()
                self.signInState = .loaded(true)
            } catch let error as APIError {
                self.signInState = .error(error.errorMessage)
            }
        }
    }
    
    func handleURLRedirect(url: URL) {
        _ = DropboxClientsManager.handleRedirectURL(url, includeBackgroundClient: false) { [weak self] authResult in
            guard let self = self else { return }
            
            switch authResult {
            case .success:
                    self.signInState = .loaded(false)
                    self.addServer()
            case .error(_, let description):
                    self.signInState = .error(description ?? "")
            default:
                    self.signInState = .error(APIError.unexpectedResponse.errorMessage)
            }
        }
    }
    
    private func addServer() {
            let server = DropboxServer()
            _ = self.mainAppModel.tellaData?.addDropboxServer(server: server)
    }
}
