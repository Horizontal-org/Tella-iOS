//
//  NearbySharingServerResponse.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/6/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

struct NearbySharingServerResponse {
    let dataResponse: Data?
    let response: ServerResponseStatus
    let endpoint: NearbySharingEndpoint?
}

enum ServerResponseStatus {
    case success
    case failure
}

