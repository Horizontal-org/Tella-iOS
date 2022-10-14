//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine

class ServersViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    // Add URL
    
    @Published var validURL : Bool = false
    @Published var shouldShowError : Bool = true
    @Published var errorMessage : String = ""
    
    // Login
    
    @Published var validUsername : Bool = false
    @Published var validPassword : Bool = false
    @Published var shouldShowLoginError : Bool = true
    @Published var loginErrorMessage : String = ""
    @Published var isLoading : Bool = false
    
    @Published var serverToAdd : Server = Server()
    
    // Server list
    @Published var servers : [Server]?
    var selectedServer : Server?
    
    private var subscribers = Set<AnyCancellable>()
    
    @Published var rootLinkIsActive : Bool = false
    @Published var showNextView : Bool = false
    
    init(mainAppModel : MainAppModel) {
        self.mainAppModel = mainAppModel
        getServers()
    }
    
    func addServer(token: String) {
        
        serverToAdd.accessToken = token
        
        do {
            let id = try mainAppModel.vaultManager.tellaData.addServer(server: serverToAdd)
            serverToAdd.id = id
            getServers()
            
        } catch {
            
        }
    }
    
    func updateServer() {
        do {
            _ = try mainAppModel.vaultManager.tellaData.updateServer(server: self.serverToAdd)
            getServers()
        } catch {
        }
    }
    
    func deleteServer() {
        do {
            _ = try mainAppModel.vaultManager.tellaData.deleteServer(server: self.serverToAdd)
            getServers()
        } catch {
        }
    }
    
    func getServers() {
        servers = mainAppModel.vaultManager.tellaData.getServers()
    }
    
    func checkURL() {
        
    }
    
    func login() {
        
        isLoading = true
        
        API.Request.Report.publisher(username: serverToAdd.username, password: serverToAdd.password, serverURL: serverToAdd.url)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    
                    switch completion {
                    case .failure(let error):
                        self.shouldShowLoginError = true
                        self.loginErrorMessage = error.message
                    case .finished:
                        self.shouldShowLoginError = false
                        self.loginErrorMessage = ""
                        self.showNextView = true
                    }
                },
                receiveValue: { wrapper in
                    self.addServer(token: wrapper.accessToken)
                }
            )
            .store(in: &subscribers)
    }
}
