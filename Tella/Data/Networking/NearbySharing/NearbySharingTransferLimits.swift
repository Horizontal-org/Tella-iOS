//
//  NearbySharingTransferLimits.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 1/4/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

struct NearbySharingTransferConfig: Sendable {
    let maxFileSizeBytes: Int64
    let maxFileCount: Int

    private static let defaultMaxFileSizeBytes: Int64 = 3_000_000_000
    private static let defaultMaxFileCount: Int = 1000

    static let standard = NearbySharingTransferConfig(
        maxFileSizeBytes: defaultMaxFileSizeBytes,
        maxFileCount: defaultMaxFileCount
    )
}

enum NearbySharingTransferLimits {

    /// `nil` if valid; otherwise a `ServerStatus` to return to the client (413 or 400).
    static func validatePrepareFiles(_ files: [NearbySharingFile]?, config: NearbySharingTransferConfig) -> ServerStatus? {
        guard let files, !files.isEmpty else {
            return ServerStatus(code: .badRequest, message: .invalidRequestFormat)
        }
        if files.count > config.maxFileCount {
            return ServerStatus(code: .payloadTooLarge, message: .contentTooLarge)
        }
        for file in files {
            guard let size = file.size, size >= 0 else {
                return ServerStatus(code: .badRequest, message: .invalidRequestFormat)
            }
            if Int64(size) > config.maxFileSizeBytes {
                return ServerStatus(code: .payloadTooLarge, message: .contentTooLarge)
            }
        }
        return nil
    }
}
