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
}
