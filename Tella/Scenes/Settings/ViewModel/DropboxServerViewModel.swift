//
//  DropboxAuthViewModel.swift
//  Tella
//
//  Created by gus valbuena on 9/3/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine
import SwiftyDropbox

class DropboxServerViewModel: ObservableObject {
    var mainAppModel: MainAppModel
    private let dropboxRepository: DropboxRepositoryProtocol
    
    @Published var signInState: ViewModelState<Bool> = .loaded(false)
    @Published var addServerState: ViewModelState<Bool> = .loaded(false)
    @Published var shouldShowSuccessScreen = false
    
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
            if Thread.isMainThread {
                self?.handleAuthResult(authResult)
            } else {
                DispatchQueue.main.async {
                    self?.handleAuthResult(authResult)
                }
            }
        }
    }
    
    private func handleAuthResult(_ authResult: DropboxOAuthResult?) {
        switch authResult {
        case .success:
            signInState = .loaded(true)
            addServer()
        case .error(_, let description):
            signInState = .error(description ?? "")
        default:
            signInState = .loaded(false)
        }
    }
    
    private func addServer() {
        addServerState = .loading
        let server = DropboxServer()
        let result = mainAppModel.tellaData?.addDropboxServer(server: server)
        
        switch result {
        case .success:
            addServerState = .loaded(true)
            shouldShowSuccessScreen = true
        case .failure(let error):
            addServerState = .error(error.localizedDescription)
        case .none:
            break
        }
    }
}
