//
//  HTTPStatusCode.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/6/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

enum HTTPStatusCode: Int, Error {
    case ok = 200
    case internalServerError = 500
    case notFound = 404
    case unauthorized = 401
    case badRequest = 400
    case forbidden = 403
    case conflict = 409
    case tooManyRequests = 429
    
    var reasonPhrase: String {
        switch self {
        case .ok: return "OK"
        case .internalServerError: return "Internal Server Error"
        case .notFound: return "Not Found"
        case .unauthorized: return "Unauthorized"
        case .badRequest: return "Invalid request format"
        case .forbidden: return "Rejected"
        case .conflict: return "Active session already exists"
        case .tooManyRequests: return "Too many requests"
        }
    }
}
