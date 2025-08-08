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
    var nonce : String?  // "random-uuid-number"
    
    init(pin: String? = nil, nonce: String? = nil) {
        self.pin = pin
        self.nonce = nonce
    }
}

struct RegisterResponse:Codable {
    var sessionId : String?
}
