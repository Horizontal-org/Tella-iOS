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
        
        mainAppModel.tellaData?.servers.sink { completion in
        } receiveValue: { serverArray in
            self.serverArray = serverArray
        }.store(in: &subscribers)
    }
    
    func deleteServer() {
        guard let serverId = self.currentServer?.id else { return  }

        if currentServer?.serverType == .uwazi {
            mainAppModel.tellaData?.deleteUwaziServer(serverId: serverId)
            
            return
        }
        
        mainAppModel.tellaData?.deleteServer(serverId: serverId)
    }
    
    func deleteAllServersConnection() {
        mainAppModel.tellaData?.deleteAllServers()
        mainAppModel.tellaData?.deleteAllServers()
    }
}
