//
//  ConnectionInfo.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/2/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation

class ConnectionInfo : Codable, Equatable {
    
    var ipAddress : String
    var port : Int
    var certificateHash : String?
    var pin : String
    
    enum CodingKeys: String, CodingKey {
        case ipAddress = "ip_address"
        case port
        case certificateHash = "certificate_hash"
        case pin
    }
    
    init(ipAddress: String, port: Int, certificateHash: String?, pin: String) {
        self.ipAddress = ipAddress
        self.port = port
        self.certificateHash = certificateHash
        self.pin = pin
    }
    
    static func == (lhs: ConnectionInfo, rhs: ConnectionInfo) -> Bool {
        lhs.ipAddress == rhs.ipAddress
    }
}

