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
    var senderCertificateHash: String?
    
    init(pin: String? = nil, nonce: String? = nil, senderCertificateHash: String?) {
        self.pin = pin
        self.nonce = nonce
        self.senderCertificateHash = senderCertificateHash
    }
}

struct RegisterResponse:Codable {
    var sessionId : String?
}
