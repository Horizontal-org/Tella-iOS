//
//  SenderClientInfo.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/6/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct SenderInfo: Codable, Equatable {
    var certificateHash: String
    
    enum CodingKeys: String, CodingKey {
        case certificateHash = "certificate_hash"
    }
    
    init(certificateHash: String) {
        self.certificateHash = certificateHash
    }
}
