//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class ServerViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    // Server propreties
    var name : String = "Name 2"
    var url : String = "https://"
    var username : String = ""
    var password : String = ""
    var activatedMetadata : Bool = false
    var backgroundUpload : Bool = false
    
    
    // Add URL
    @Published var validURL : Bool = false
    @Published var shouldShowURLError : Bool = false
    @Published var urlErrorMessage : String = ""
    @Published var showNextLoginView : Bool = false
    
    // Login
    @Published var validUsername : Bool = false
    @Published var validPassword : Bool = false
    @Published var validCredentials : Bool = false
    @Published var shouldShowLoginError : Bool = false
    @Published var loginErrorMessage : String = ""
    @Published var isLoading : Bool = false
    @Published var showNextSuccessLoginView : Bool = false
    
    private var cancellable: Cancellable? = nil
    
    var currentServer : Server?
    
    init(mainAppModel : MainAppModel, currentServer: Server?) {
        
        self.mainAppModel = mainAppModel
        self.currentServer = currentServer
        
        cancellable = $validUsername.combineLatest($validPassword).sink(receiveValue: { validUsername, validPassword  in
            self.validCredentials = validUsername && validPassword
        })
        
        fillReportVM()
        
    }
    
    func addServer(token: String) {
        
        let server = Server(name: name,
                            url: url,
                            username: username,
                            password: password,
                            accessToken: token,
                            activatedMetadata: activatedMetadata,
                            backgroundUpload: backgroundUpload)
        
        do {
            let id = try mainAppModel.vaultManager.tellaData.addServer(server: server)
            server.id = id
            
            self.currentServer = server
            
        } catch {
            
        }
    }
    
    func updateServer() {
        do {
            
            guard let currentServer = self.currentServer else { return  }
            currentServer.backgroundUpload = backgroundUpload
            currentServer.activatedMetadata = activatedMetadata
            
            _ = try mainAppModel.vaultManager.tellaData.updateServer(server: currentServer)
        } catch {
            
        }
    }
    
    func checkURL() {
        
        isLoading = true
        
        API.Request.Server.publisher(serverURL: url)
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
        
        API.Request.Server.publisher(username: username, password: password, serverURL: url)
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
    
    
    func fillReportVM() {
        if let server = self.currentServer {
            name =  server.name ?? ""
            url = server.url ?? ""
            username = server.username ?? ""
            password = server.password ?? ""
            activatedMetadata = server.activatedMetadata ?? false
            backgroundUpload = server.backgroundUpload ?? false
        }
    }
    
}
