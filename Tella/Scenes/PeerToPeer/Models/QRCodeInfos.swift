//
//  QRCodeInfos.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/2/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//


class QRCodeInfos : Codable, Equatable {
    
    var ipAddress : String
    var pin : String
    var hash : String
    
    init(ipAddress: String, pin: String, hash: String) {
        self.ipAddress = ipAddress
        self.pin = pin
        self.hash = hash
    }
    
    static func == (lhs: QRCodeInfos, rhs: QRCodeInfos) -> Bool {
        lhs.ipAddress == rhs.ipAddress
    }

}
