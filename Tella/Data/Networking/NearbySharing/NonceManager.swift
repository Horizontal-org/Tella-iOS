//
//  NonceManager.swift
//  Tella
//
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

/// Single-use nonce tracking for nearby sharing transfer endpoints.
final class NonceManager {
    
    private var seen = Set<String>()
    private let lock = NSLock()
    
    enum NonceError: Error {
        case zeroLength
        case reuse
    }
    
    /// Registers a nonce. Returns `false` if it is empty or already registered.
    func add(_ nonce: String) throws {
        lock.lock()
        defer { lock.unlock() }
        guard !nonce.isEmpty else {
            throw NonceError.zeroLength
        }
        guard !seen.contains(nonce) else {
            throw NonceError.reuse
        }
        seen.insert(nonce)
    }
    
    func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        seen.removeAll()
    }
}

extension NonceManager.NonceError {
    var serverStatus: ServerStatus {
        switch self {
        case .zeroLength:
            ServerStatus(code: .conflict, message: .nonceZeroLength)
        case .reuse:
            ServerStatus(code: .conflict, message: .nonceReuse)
        }
    }
}
