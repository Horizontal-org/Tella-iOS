//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class ServerViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    // Server propreties
    @Published var name : String?
    @Published var projectURL : String = "https://"
    @Published var username : String = ""
    @Published var password : String = ""
    @Published var activatedMetadata : Bool = false
    @Published var backgroundUpload : Bool = false
    @Published var autoUpload : Bool = false
    @Published var autoDelete : Bool = false

    
    // Add URL
    @Published var validURL : Bool = false
    @Published var shouldShowURLError : Bool = false
    @Published var urlErrorMessage : String = ""
    
    // Login
    @Published var validUsername : Bool = false
    @Published var validPassword : Bool = false
    @Published var validCredentials : Bool = false
    @Published var shouldShowLoginError : Bool = false
    @Published var loginErrorMessage : String = ""
    @Published var isLoading : Bool = false
    @Published var showNextSuccessLoginView : Bool = false
    
    private var cancellable: Cancellable? = nil
    var subscribers = Set<AnyCancellable>()

    var currentServer : TellaServer?
    
    var isAutoUploadServerExist: Bool {
        return mainAppModel.vaultManager.tellaData?.getAutoUploadServer() != nil && self.currentServer?.autoUpload == false
    }
    
    init(mainAppModel : MainAppModel, currentServer: TellaServer?) {
        self.mainAppModel = mainAppModel
        self.currentServer = currentServer
        cancellable = $validUsername.combineLatest($validPassword).sink(receiveValue: { validUsername, validPassword  in
            self.validCredentials = validUsername && validPassword
        })
        fillReportVM()
    }
    
    func addServer(token: String, project: ProjectAPI) {
        let server = TellaServer(name: project.name,
                            serverURL: projectURL.getBaseURL(),
                            username: username,
                            password: password,
                            accessToken: token,
                            activatedMetadata: activatedMetadata,
                            backgroundUpload: backgroundUpload,
                            projectId: project.id,
                            slug: project.slug,
                            autoUpload: autoUpload,
                            autoDelete: autoDelete)
        
        
        let addServerResult = mainAppModel.vaultManager.tellaData?.addServer(server: server)
        
        if case .success(let id) = addServerResult {
            server.id = id
            self.currentServer = server
        }
        
    }
    
    func updateServer() {
 
            guard let currentServer = self.currentServer else { return  }
            currentServer.backgroundUpload = backgroundUpload
            currentServer.activatedMetadata = activatedMetadata
            currentServer.autoUpload = autoUpload
            currentServer.autoDelete = autoDelete

            mainAppModel.vaultManager.tellaData?.updateServer(server: currentServer)
     }

    func login() {
        
        guard let baseURL = projectURL.getBaseURL() else { return }

        isLoading = true
        
        ServerRepository().login(username: username, password: password, serverURL: baseURL)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    
                    switch completion {
                    case .failure(let error):
                        self.shouldShowLoginError = true
                        self.loginErrorMessage = error.errorDescription ?? ""
                        self.isLoading = false

                    case .finished:
                        break
                        
                    }
                },
                receiveValue: { result in
                    self.getProjetSlug(token: result.accessToken)
                }
            )
            .store(in: &subscribers)
    }
    
    
    func getProjetSlug(token: String) {
        
//        isLoading = true

        ServerRepository().getProjetDetails(projectURL: projectURL, token: token)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    
                    switch completion {
                    case .failure(let error):
                        self.shouldShowLoginError = true
                        self.loginErrorMessage = error.errorDescription ?? ""
                    case .finished:
                        self.shouldShowLoginError = false
                        self.loginErrorMessage = ""
                        self.showNextSuccessLoginView = true
                    }
                },
                receiveValue: { project in
                    self.addServer(token: token,project: project)
                }
            )
            .store(in: &subscribers)

    }
    
    
    func fillReportVM() {
        if let server = self.currentServer {
            name =  server.name ?? ""
            projectURL = server.url ?? ""
            username = server.username ?? ""
            password = server.password ?? ""
            activatedMetadata = server.activatedMetadata ?? false
            backgroundUpload = server.backgroundUpload ?? false
            autoUpload = server.autoUpload ?? false
            autoDelete = server.autoDelete ?? false
        }
    }
    
}
