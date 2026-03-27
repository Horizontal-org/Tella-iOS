//
//  RegistrationNonceContext.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

struct RegistrationNonceContext: Equatable {
    let ipAddress: String
    let port: Int
    let pin: String
    let nonce: String
}

extension RegistrationNonceContext {
    func matches(_ connectionInfo: ConnectionInfo) -> Bool {
        ipAddress == connectionInfo.ipAddress &&
            port == connectionInfo.port &&
            pin == connectionInfo.pin
    }

    /// Reuses the nonce for the same target until `context` is cleared after a successful registration.
    static func nonce(for connectionInfo: ConnectionInfo, context: inout RegistrationNonceContext?) -> String {
        if let stored = context, stored.matches(connectionInfo) {
            return stored.nonce
        }
        let nonce = UUID().uuidString
        context = RegistrationNonceContext(
            ipAddress: connectionInfo.ipAddress,
            port: connectionInfo.port,
            pin: connectionInfo.pin,
            nonce: nonce
        )
        return nonce
    }
}
