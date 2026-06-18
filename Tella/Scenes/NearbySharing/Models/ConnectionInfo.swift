//
//  ConnectionInfo.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/2/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Security

class ConnectionInfo: Codable, Equatable {
    
    var ipAddresses: [String]
    var port: Int
    var certificateHash: String?
    var pin: String
    var protocolVersion: Int?
    /// Receiver QR only: when true (e.g. desktop receiver that can't scan), the sender skips showing its QR and goes directly to sender hash verification.
    var senderShowHash: Bool?
    
    /// After a successful register against one of `ipAddresses`, HTTPS calls use this host. Not part of the QR JSON.
    var activeHost: String?
    var clientTLSIdentity: SecIdentity?
    
    var requestHost: String {
        if let activeHost, !activeHost.isEmpty { return activeHost }
        return ipAddresses.first ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case ipAddresses = "ip_address"
        case port
        case certificateHash = "certificate_hash"
        case pin
        case protocolVersion = "protocol_version"
    }
    
    init(
        ipAddresses: [String],
        port: Int,
        certificateHash: String?,
        pin: String,
        protocolVersion: Int? = NearbySharingProtocolVersion.current,
        senderShowHash: Bool? = nil
    ) {
        self.ipAddresses = ipAddresses
        self.port = port
        self.certificateHash = certificateHash
        self.pin = pin
        self.protocolVersion = protocolVersion
        self.senderShowHash = senderShowHash
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        port = try container.decode(Int.self, forKey: .port)
        certificateHash = try container.decodeIfPresent(String.self, forKey: .certificateHash)
        pin = try container.decode(String.self, forKey: .pin)
        ipAddresses = try container.decode([String].self, forKey: .ipAddresses)
        protocolVersion = try container.decodeIfPresent(Int.self, forKey: .protocolVersion)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ipAddresses, forKey: .ipAddresses)
        try container.encode(port, forKey: .port)
        try container.encodeIfPresent(certificateHash, forKey: .certificateHash)
        try container.encode(pin, forKey: .pin)
        try container.encodeIfPresent(protocolVersion, forKey: .protocolVersion)
    }
    
    /// Returns nil when the QR payload is compatible, otherwise an error reason for the UI.
    func protocolCompatibilityError() -> ProtocolCompatibilityError? {
        guard let version = protocolVersion else {
            return .incompatibleVersion
        }
        guard NearbySharingProtocolVersion.supportedVersions.contains(version) else {
            return .incompatibleVersion
        }
        return nil
    }
    
    static func == (lhs: ConnectionInfo, rhs: ConnectionInfo) -> Bool {
        lhs.ipAddresses == rhs.ipAddresses
        && lhs.port == rhs.port
        && lhs.pin == rhs.pin
        && lhs.certificateHash == rhs.certificateHash
        && lhs.protocolVersion == rhs.protocolVersion
    }
}

enum ProtocolCompatibilityError {
    case incompatibleVersion
}

extension ConnectionInfo {
    static func stub() -> ConnectionInfo {
        ConnectionInfo(
            ipAddresses: ["192.1.2.6"],
            port: 53317,
            certificateHash: "764357",
            pin: "983426"
        )
    }
}
