//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

// MARK: - LoginResult

struct LoginResult: Codable {
    let accessToken: String
    let user: User

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}

// MARK: - User
struct User: Codable {
    let id, username, role, createdAt: String
}
