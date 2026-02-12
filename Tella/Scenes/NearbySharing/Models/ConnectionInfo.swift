//
//  ConnectionInfo.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/2/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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

extension ConnectionInfo {
    static func stub() -> ConnectionInfo {
        return ConnectionInfo(ipAddress: "192.1.2.6", port: 53317, certificateHash: "764357", pin: "983426")
    }
}
