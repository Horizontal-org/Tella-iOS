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
    @Published var shouldShowURLError : Bool = false
    @Published var urlErrorMessage : String = ""
    @Published var showNextLoginView : Bool = false
    @Published var rootLinkIsActive : Bool = false
    
    // Login
    @Published var validUsername : Bool = false
    @Published var validPassword : Bool = false
    @Published var validCredentials : Bool = false
    @Published var shouldShowLoginError : Bool = false
    @Published var loginErrorMessage : String = ""
    @Published var isLoading : Bool = false
    @Published var showNextSuccessLoginView : Bool = false
    
    // Current Server
    @Published var currentServer : Server = Server()
    
    // Server list
    @Published var servers : [Server]?
    
    private var subscribers = Set<AnyCancellable>()
    private var cancellable: Cancellable? = nil
    
    
    init(mainAppModel : MainAppModel) {
        self.mainAppModel = mainAppModel
        
        cancellable = $validUsername.combineLatest($validPassword).sink(receiveValue: { validUsername, validPassword  in
            self.validCredentials = validUsername && validPassword
        })
        
        getServers()
    }
    
    func getServers() {
        servers = mainAppModel.vaultManager.tellaData.getServers()
    }
    
    func addServer(token: String) {
        
        currentServer.accessToken = token
        
        do {
            let id = try mainAppModel.vaultManager.tellaData.addServer(server: currentServer)
            currentServer.id = id
            getServers()
        } catch {
            
        }
    }
    
    func updateServer() {
        do {
            _ = try mainAppModel.vaultManager.tellaData.updateServer(server: self.currentServer)
            getServers()
        } catch {
        }
    }
    
    func deleteServer() {
        do {
            _ = try mainAppModel.vaultManager.tellaData.deleteServer(server: self.currentServer)
            getServers()
        } catch {
        }
    }
    
    func checkURL() {
        
        isLoading = true
        
        API.Request.Server.publisher(serverURL: currentServer.url)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    
                    switch completion {
                    case .failure(let error):
                        
                        if error.code == 400 {
                            self.shouldShowURLError = false
                            self.urlErrorMessage = ""
                            self.showNextLoginView = true
                            
                            
                        } else {
                            
                            self.shouldShowURLError = true
                            self.urlErrorMessage = error.message
                            
                            
                        }
                        
                    case .finished:
                        break
                    }
                },
                receiveValue: { wrapper in
                }
            )
            .store(in: &subscribers)
    }
    
    func login() {
        
        isLoading = true
        
        API.Request.Server.publisher(username: currentServer.username, password: currentServer.password, serverURL: currentServer.url)
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
                        self.showNextSuccessLoginView = true
                    }
                },
                receiveValue: { wrapper in
                    self.addServer(token: wrapper.accessToken)
                }
            )
            .store(in: &subscribers)
    }
    
    func initServerVM() {
        
        validURL = false
        shouldShowURLError = false
        urlErrorMessage = ""
        
        validUsername = false
        validPassword = false
        validCredentials = false
        shouldShowLoginError = false
        loginErrorMessage = ""
        
        rootLinkIsActive = false
        showNextSuccessLoginView = false
        showNextLoginView = false
        
        currentServer = Server()
    }
}
