//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import Foundation

class ServerDataItem: Hashable {
    
    
    var servers : [Server]
    var serverType : ServerConnectionType
    
    init(servers: [Server], serverType: ServerConnectionType) {
        self.servers = servers
        self.serverType = serverType
    }
    
    static func == (lhs: ServerDataItem, rhs: ServerDataItem) -> Bool {
        lhs.serverType == rhs.serverType
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(serverType.hashValue)
    }


}
