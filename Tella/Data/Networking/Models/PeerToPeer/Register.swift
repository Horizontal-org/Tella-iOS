//
//  Register.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/3/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

struct RegisterRequest:Codable {
    var pin : String?
    var nonce : String?  // "random-uuid-number"
}

struct RegisterResponse:Codable {
    var sessionId : String?
}
