//
//  Register.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

struct RegisterRequest:Codable {
    var pin : String?
    var nonce : String?
    
    init(pin: String? = nil, nonce: String? = nil) {
        self.pin = pin
        self.nonce = nonce
    }
}

struct RegisterResponse:Codable {
    var sessionId : String?
}

struct PingResponse: Codable {
    var senderShowHash: Bool
}

struct NearbySharingPingResult {
    let certificateHash: String
    let senderShowHash: Bool
}
