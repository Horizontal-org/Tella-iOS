//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

// MARK: - LoginResult
struct LoginResult: Codable {
    let accessToken: String?
    let user: User?
    let version: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
        case version
    }
}

// MARK: - User
struct User: Codable {
    let id, username, role, createdAt: String?
}
