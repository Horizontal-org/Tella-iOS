//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine

class ServersViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published var currentServer : Server?
    @Published var serverArray : [Server] = []
    
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel : MainAppModel) {
        
        self.mainAppModel = mainAppModel
        
        mainAppModel.vaultManager.tellaData.servers.sink { completion in
        } receiveValue: { serverArray in
            self.serverArray = serverArray
        }.store(in: &subscribers)
    }
    
    func deleteServer() {
        guard let serverId = self.currentServer?.id else { return  }
        do {
              try mainAppModel.vaultManager.tellaData.deleteServer(serverId: serverId)
                if currentServer?.slug == "" || currentServer?.slug == nil {
                    try mainAppModel.vaultManager.tellaData.database?.deleteUwaziLocaleWith(serverId: serverId)
                }
        } catch {
        }
    }
    
    func deleteAllServersConnection() {
        do {
            _ = try mainAppModel.vaultManager.tellaData.deleteAllServers()
        } catch {
        }
    }
}
