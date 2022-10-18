//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

extension API.Request {
    struct Server {}
}

extension API.Request.Server: APIRequest {
    
    typealias ResultType = LoginResult

    enum Key: String, KeyType {
        case username = "username"
        case password = "password"
    }
    
    static var startURLPath: String? { "/login" }
    
    static var httpMethod: Request.HTTPMethod {.post}
}

extension API.Request.Server {
    
    static func publisher(username: String,
                          password: String,
                          serverURL: String) -> AnyPublisher<ResultType, TellaError> {
        publisher(keyValues: [
                .username: username,
                .password: password],
            serverURL: serverURL)
    }
    
    static func publisher(serverURL: String) -> AnyPublisher<ResultType, TellaError> {
        publisher(keyValues: nil,
                  serverURL: serverURL)
    }

}
