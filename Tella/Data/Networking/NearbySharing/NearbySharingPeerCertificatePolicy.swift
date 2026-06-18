//
//  NearbySharingPeerCertificatePolicy.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 11/6/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

final class NearbySharingPeerCertificatePolicy: @unchecked Sendable {
    
    private let lock = NSLock()
    private var trustedPeerCertificateHash: String?
    private var pendingPeerCertificateHash: String?
    
    func reset() {
        lock.lock()
        trustedPeerCertificateHash = nil
        pendingPeerCertificateHash = nil
        lock.unlock()
    }
    
    func setTrustedPeerCertificateHash(_ hash: String) {
        lock.lock()
        trustedPeerCertificateHash = hash
        pendingPeerCertificateHash = nil
        lock.unlock()
    }
    
    func consumePendingPeerCertificateHash() -> String? {
        lock.lock()
        defer { lock.unlock() }
        let hash = pendingPeerCertificateHash
        pendingPeerCertificateHash = nil
        return hash
    }
    
    func peekPendingPeerCertificateHash() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return pendingPeerCertificateHash
    }
    
    func hasTrustedPeerCertificateHash() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return trustedPeerCertificateHash != nil
    }
    
    func evaluatePeerTrust(_ secTrust: sec_trust_t) -> Bool {
        let trust = sec_trust_copy_ref(secTrust).takeRetainedValue()
        guard let hash = trust.certificateHash else {
            return false
        }
        
        lock.lock()
        defer { lock.unlock() }
        
        if let trusted = trustedPeerCertificateHash {
            return trusted == hash
        }
        
        pendingPeerCertificateHash = hash
        return true
    }
}
