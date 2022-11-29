//
//  ServerDataItem.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 29/11/2022.
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class ServerDataItem: Hashable {
    
    
    var servers : [Server]
    var serverType : ServerType
    
    init(servers: [Server], serverType: ServerType) {
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
