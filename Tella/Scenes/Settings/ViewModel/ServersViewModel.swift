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
    @Published var unavailableServers: [Server] = []
    
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel : MainAppModel) {
        
        self.mainAppModel = mainAppModel
        
        mainAppModel.tellaData?.servers.sink { completion in
        } receiveValue: { serverArray in
            self.serverArray = serverArray
            self.unavailableServers = serverArray.filter { $0.allowMultiple == false }
        }.store(in: &subscribers)
    }
    
    func deleteServer() {
        guard let server = self.currentServer else { return }
        
        mainAppModel.tellaData?.deleteServer(server: server)
    }
    
    func deleteAllServersConnection() {
        mainAppModel.tellaData?.deleteAllServers()
    }
    
    func filterServerConnections() -> [ServerConnectionButton] {
        if(self.unavailableServers.isEmpty) {
            return serverConnections
        }
        
        return serverConnections.filter { connection in
            unavailableServers.contains{ connection.type != $0.serverType }
        }
        
    }
}
