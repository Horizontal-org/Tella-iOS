//
//  HTTPRequest.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/6/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

struct HTTPRequest {
    var endpoint: String
    var queryParameters: [String:String]
    var headers: Headers
    var body: String
    var bodyFullyReceived: Bool
}

struct Headers {
    var contentLength: Int?
    var contentType: String?
}
