//
//  NextcloudServerViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

class NextcloudServerViewModel: ServerViewModel {
    
    private var nextcloudRepository: NextCloudRepository
    private var mainAppModel: MainAppModel
    
    var currentServer: NextcloudServer?
    
    init(nextcloudRepository: NextCloudRepository = NextCloudRepository(),
         mainAppModel: MainAppModel,
         currentServer: NextcloudServer? = nil) {
        self.nextcloudRepository = nextcloudRepository
        self.mainAppModel = mainAppModel
        self.currentServer = currentServer
    }
    
    override func checkURL() {
        checkServerState = .loading
        Task { @MainActor in
            do {
                try await nextcloudRepository.checkServer(serverUrl: serverURL)
                checkServerState = .loaded(true)
            }
            catch let error{
                checkServerState = .error(error.localizedDescription)
            }
        }
    }
    
    override func login() {
        loginState = .loading
        Task { @MainActor in
            do {
                try await nextcloudRepository.login(serverUrl: serverURL, username: username, password: password)
                loginState = .loaded(true)
            }
            catch let error{
                loginState = .error(error.localizedDescription)
            }
        }
    }
    
    func addServer() {
        let server = NextcloudServer(serverURL: serverURL, username: username, password: password)
        let serverID = mainAppModel.tellaData?.addNextcloudServer(server: server)
        
        guard let serverID else {
            return
        }
        server.id = serverID
        self.currentServer = server
    }
    
    func updateServer() {
//        guard let currentServer = self.currentServer as? NextcloudServer  else { return  }
//        currentServer.userId = userId
//        currentServer.rootFolder = rootFolder
//        mainAppModel.tellaData?.updateNextcloudServer(server: currentServer)
    }
    
}
