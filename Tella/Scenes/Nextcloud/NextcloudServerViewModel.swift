//
//  NextcloudServerViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

class NextcloudServerViewModel: ServerViewModel {
    
    private var nextcloudRepository: NextCloudRepository

    init(nextcloudRepository: NextCloudRepository = NextCloudRepository()) {
        self.nextcloudRepository = nextcloudRepository
    }
    
    override func checkURL() {
//        self.isLoading = true
        nextcloudRepository.checkServer(serverUrl: serverURL)
    }
    
//    func addServer() {
//        let server = NextcloudServer(serverURL: serverURL, username: username, password: password)
//        
//        let serverID = mainAppModel.tellaData?.addNextcloudServer(server: server)
//        
//        guard let serverID else {
//            return
//        }
//        server.id = serverID
//        self.currentServer = server
//    }
//    
//    
//    func updateServer() {
//        guard let currentServer = self.currentServer as? NextcloudServer  else { return  }
//        currentServer.userId = userId
//        currentServer.rootFolder = rootFolder
//        mainAppModel.tellaData?.updateNextcloudServer(server: currentServer)
//    }
    
    
}
