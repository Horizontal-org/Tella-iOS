//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

class TellaWebServerViewModel: ServerViewModel {
    
    var mainAppModel : MainAppModel
    
    // Server propreties
    @Published var name : String?
    @Published var projectURL : String = "https://"
    @Published var activatedMetadata : Bool = false
    @Published var backgroundUpload : Bool = false
    @Published var autoUpload : Bool = false
    @Published var autoDelete : Bool = false
    
    var subscribers = Set<AnyCancellable>()

    var currentServer : TellaServer?
    
    var isAutoUploadServerExist: Bool {
        return mainAppModel.tellaData?.getAutoUploadServer() != nil && self.currentServer?.autoUpload == false
    }
    
    init(mainAppModel : MainAppModel, currentServer: TellaServer?) {
        self.mainAppModel = mainAppModel
        self.currentServer = currentServer
        super.init()
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
        
        
        let addServerResult = mainAppModel.tellaData?.addServer(server: server)
        
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

            mainAppModel.tellaData?.updateServer(server: currentServer)
     }

    override func login() {
        
        guard let baseURL = projectURL.getBaseURL() else { return }

        isLoading = true
        
        ServerRepository().login(username: username, password: password, serverURL: baseURL)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    
                    switch completion {
                    case .failure(let error):
                        self.shouldShowLoginError = true
                        self.loginErrorMessage = error.errorMessage
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
                        self.loginErrorMessage = error.errorMessage
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
