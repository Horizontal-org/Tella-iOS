//
//  CloseConnection.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

// MARK: - CloseConnectionRequest
struct CloseConnectionRequest: Codable {
    let sessionID: String?

    enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
    }
}
