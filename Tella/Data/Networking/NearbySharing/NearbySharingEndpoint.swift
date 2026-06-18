//
//  NearbySharingEndpoint.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/6/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

enum NearbySharingEndpoint: String {
    case ping = "/api/v2/ping"
    case register = "/api/v2/register"
    case prepareUpload = "/api/v2/prepare-upload"
    case upload = "/api/v2/upload"
    case closeConnection = "/api/v2/close-connection"

    /// v1 routes used only to detect incompatibility.
    private static let v1Routes: Set<String> = [
        "/api/v1/register",
        "/api/v1/ping"
    ]

    static func isV1Route(_ path: String) -> Bool {
        v1Routes.contains(path)
    }

    static func apiVersion(from path: String) -> Int? {
        let components = path.split(separator: "/", omittingEmptySubsequences: true)

        guard components.count >= 2,
              components[0] == "api",
              components[1].hasPrefix("v") else {
            return nil
        }

        return Int(components[1].dropFirst())
    }

    static func isPingOrRegister(path: String) -> Bool {
        guard let routeName = path
            .split(separator: "/", omittingEmptySubsequences: true)
            .last else {
            return false
        }

        return routeName == "ping" || routeName == "register"
    }
}
