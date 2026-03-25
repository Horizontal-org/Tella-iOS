//
//  HTTPStatusCode.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/6/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

enum HTTPStatusCode: Int, Error {
    case ok = 200
    case internalServerError = 500
    case notFound = 404
    case unauthorized = 401
    case badRequest = 400
    case forbidden = 403
    case conflict = 409
    case notAcceptable = 406
    case tooManyRequests = 429
    case insufficientStorage = 507
}

enum ServerMessage: String {
    case ok = "OK"
    case invalidRequestFormat = "Invalid request format"
    case invalidPIN = "Invalid PIN"
    case activeSessionAlreadyExists = "Active session already exists"
    case tooManyRequests = "Too many requests"
    case invalidSessionID = "Invalid session ID"
    case rejected = "Rejected"
    case invalidTransmissionID = "Invalid transmission ID"
    case transferAlreadyCompleted = "Transfer already completed"
    case fileHashMismatch = "File hash mismatch"
    case sessionAlreadyClosed = "Session already closed"
    case serverError = "Server error"
    case insufficientStorage = "Insufficient Storage"
    case transferNotFound = "Transfer not found"

    
}

struct ServerStatus : Error {
    let code : HTTPStatusCode
    let message : ServerMessage
}

extension Error {
    /// POSIX `ENOSPC` or Cocoa out-of-space from file APIs.
    var isInsufficientStorageError: Bool {
        let ns = self as NSError
        if ns.domain == NSPOSIXErrorDomain, ns.code == 28 { return true }
        if ns.domain == NSCocoaErrorDomain, ns.code == NSFileWriteOutOfSpaceError { return true }
        return false
    }
}
