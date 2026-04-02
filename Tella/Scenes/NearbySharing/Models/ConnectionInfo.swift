//
//  ConnectionInfo.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/2/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

class ConnectionInfo: Codable, Equatable {

    var ipAddresses: [String]
    var port: Int
    var certificateHash: String?
    var pin: String

    /// After a successful register against one of `ipAddresses`, HTTPS calls use this host. Not part of the QR JSON.
    var activeHost: String?

    var requestHost: String {
        if let activeHost, !activeHost.isEmpty { return activeHost }
        return ipAddresses.first ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case ipAddresses = "ip_address"
        case port
        case certificateHash = "certificate_hash"
        case pin
    }

    init(ipAddresses: [String], port: Int, certificateHash: String?, pin: String) {
        self.ipAddresses = ipAddresses
        self.port = port
        self.certificateHash = certificateHash
        self.pin = pin
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        port = try container.decode(Int.self, forKey: .port)
        certificateHash = try container.decodeIfPresent(String.self, forKey: .certificateHash)
        pin = try container.decode(String.self, forKey: .pin)
        ipAddresses = try container.decode([String].self, forKey: .ipAddresses)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ipAddresses, forKey: .ipAddresses)
        try container.encode(port, forKey: .port)
        try container.encodeIfPresent(certificateHash, forKey: .certificateHash)
        try container.encode(pin, forKey: .pin)
    }

    static func == (lhs: ConnectionInfo, rhs: ConnectionInfo) -> Bool {
        lhs.ipAddresses == rhs.ipAddresses
            && lhs.port == rhs.port
            && lhs.pin == rhs.pin
            && lhs.certificateHash == rhs.certificateHash
    }
}

extension ConnectionInfo {
    static func stub() -> ConnectionInfo {
        ConnectionInfo(ipAddresses: ["192.1.2.6"], port: 53317, certificateHash: "764357", pin: "983426")
    }
}




