//
//  NearbySharingRateLimiter.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 30/3/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

//  Behavior:
//  - limit per IP + route
//  - allow initial burst of 1000 requests
//  - refill 1 request every 30 seconds
//  - forget inactive buckets after 24 hours
//  - if limited, caller should ignore request contents and return 429
//

import Foundation
import Network

enum NearbySharingClientIP {
    static func string(from connection: NWConnection) -> String {
        if case .hostPort(let host, _) = connection.endpoint {
            return string(from: host)
        }

        if let remote = connection.currentPath?.remoteEndpoint,
           case .hostPort(let host, _) = remote {
            return string(from: host)
        }

        return "unknown"
    }

    private static func string(from host: NWEndpoint.Host) -> String {
        switch host {
        case .ipv4(let address):
            return address.debugDescription
        case .ipv6(let address):
            return address.debugDescription
        case .name(let name, _):
            return name
        @unknown default:
            return String(describing: host)
        }
    }
}

actor NearbySharingRateLimiter {

    private struct Bucket {
        var tokens: Double
        var lastRefill: Date
        var lastSeen: Date
    }

    /// - refresh one access every 30 seconds
    /// - forget requester after 24h of inactivity
    /// - allow initial burst of 1000
    private let refreshPeriod: TimeInterval
    private let burstAllowance: Double
    private let inactivityTTL: TimeInterval

    /// Key format: "<ip>|<route>"
    private var buckets: [String: Bucket] = [:]

    init(
        refreshPeriod: TimeInterval = 30,
        burstAllowance: Double = 1000,
        inactivityTTL: TimeInterval = 24 * 60 * 60
    ) {
        self.refreshPeriod = refreshPeriod
        self.burstAllowance = burstAllowance
        self.inactivityTTL = inactivityTTL
    }

    /// Returns true when the request must be rejected with 429.
    /// One token is consumed only when the request is allowed.
    func isLimited(ip: String, route: String) -> Bool {
        let now = Date()
        cleanupExpiredBuckets(now: now)

        let key = makeKey(ip: ip, route: route)
        var bucket = buckets[key] ?? Bucket(
            tokens: burstAllowance,
            lastRefill: now,
            lastSeen: now
        )

        let elapsed = max(0, now.timeIntervalSince(bucket.lastRefill))
        let replenishedTokens = elapsed / refreshPeriod
        bucket.tokens = min(burstAllowance, bucket.tokens + replenishedTokens)
        bucket.lastRefill = now
        bucket.lastSeen = now

        let limited = bucket.tokens < 1
        if !limited {
            bucket.tokens -= 1
        }

        buckets[key] = bucket
        return limited
    }

    func reset() {
        buckets.removeAll()
    }

    private func makeKey(ip: String, route: String) -> String {
        "\(ip)|\(route)"
    }

    private func cleanupExpiredBuckets(now: Date) {
        buckets = buckets.filter { _, bucket in
            now.timeIntervalSince(bucket.lastSeen) < inactivityTTL
        }
    }
}
