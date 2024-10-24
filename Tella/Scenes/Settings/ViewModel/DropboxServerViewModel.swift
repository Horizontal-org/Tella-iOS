//
//  DropboxAuthViewModel.swift
//  Tella
//
//  Created by gus valbuena on 9/3/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class DropboxServerViewModel: ObservableObject {
    var mainAppModel: MainAppModel
    private let dropboxRepository: DropboxRepositoryProtocol
    
    @Published var signInState: ViewModelState<Bool> = .loaded(false)
    @Published var addServerState: ViewModelState<Bool> = .loaded(false)
    
    init(dropboxRepository: DropboxRepositoryProtocol, mainAppModel: MainAppModel) {
        self.dropboxRepository = dropboxRepository
        self.mainAppModel = mainAppModel
    }
    
    func handleSignIn() {
        self.signInState = .loading
        Task { @MainActor in
            do {
                try await dropboxRepository.handleSignIn()
            } catch let error as APIError {
                self.signInState = .error(error.errorMessage)
            }
        }
    }
    
    func handleURLRedirect(url: URL) {
        _ = dropboxRepository.handleRedirectURL(url) { [weak self] authResult in
            guard let self = self else { return }
            
            switch authResult {
            case .success:
                self.signInState = .loaded(true)
                self.addServer()
            case .error(_, let description):
                self.signInState = .error(description ?? "")
            default:
                break
            }
        }
    }
    
    private func addServer() {
        self.addServerState = .loading
        let server = DropboxServer()
        let result = self.mainAppModel.tellaData?.addDropboxServer(server: server)
        
        switch result {
        case .success:
            self.addServerState = .loaded(true)
        case .failure(let error):
            self.addServerState = .error(error.localizedDescription)
        case .none:
            break
        }
    }
}
