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
    
    @Published var signInState: ViewModelState<String?> = .loaded(nil)
    private var authCompletion: (() -> Void)?
    
    init(dropboxRepository: DropboxRepositoryProtocol, mainAppModel: MainAppModel) {
        self.dropboxRepository = dropboxRepository
        self.mainAppModel = mainAppModel
    }
    
    func handleSignIn(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.signInState = .loading
            self.authCompletion = completion
        }
        
        Task {
            do {
                try await dropboxRepository.handleSignIn()
            } catch let error as APIError {
                DispatchQueue.main.async {
                    self.signInState = .error(error.errorMessage)
                }
            }
        }
    }
    
    func handleURLRedirect(url: URL) {
        _ = DropboxClientsManager.handleRedirectURL(url, includeBackgroundClient: false) { [weak self] authResult in
            guard let self = self else { return }
            
            switch authResult {
            case .success:
                DispatchQueue.main.async {
                    self.signInState = .loaded(nil)
                    self.addServer()
                    self.authCompletion?()
                    self.authCompletion = nil
                }
            case .error(_, let description):
                DispatchQueue.main.async {
                    self.signInState = .error(description ?? "")
                    self.authCompletion = nil
                }
            default:
                DispatchQueue.main.async {
                    self.signInState = .error(APIError.unexpectedResponse.errorMessage)
                    self.authCompletion = nil
                }
            }
        }
    }
    
    private func addServer() {
        DispatchQueue.main.async {
            let server = DropboxServer()
            _ = self.mainAppModel.tellaData?.addDropboxServer(server: server)
        }
    }
}
