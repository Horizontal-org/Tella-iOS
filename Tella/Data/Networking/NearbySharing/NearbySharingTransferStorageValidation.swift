//
//  NearbySharingTransferStorageValidation.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 21/4/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

enum NearbySharingTransferStorageValidation {

    // MARK: - Tunables

    /// Extra bytes beyond the “declared content” model (I/O buffers, filesystem metadata, etc.)
    private static let diskSafetyMarginBytes: Int64 = 10 * 1024 * 1024

    /// Per-call multiplier applied to **declared** payload size before comparing to `availableDiskSpace`.
    /// We use `2` to mirror the single-upload path (`beginUpload`): room for a temp copy + safety margin while a file is in flight.
    private static let declaredContentDiskMultiplier: Int64 = 2

    static func validateStorage(forContentSizeBytes total: Int64) -> ServerStatus? {
        let requiredSpace = (total * declaredContentDiskMultiplier) + diskSafetyMarginBytes
        guard FileManager.default.availableDiskSpace >= requiredSpace else {
            return ServerStatus(code: .insufficientStorage, message: .insufficientStorage)
        }
        return nil
    }

    static func validateBatchStorageAgainstLocalDisk(_ files: [NearbySharingFile]?) -> ServerStatus? {
        guard let files, !files.isEmpty else { return nil }
        var totalSize: Int64 = 0
        for file in files {
            guard let size = file.size, size >= 0 else {
                return ServerStatus(code: .badRequest, message: .invalidRequestFormat)
            }
            totalSize += Int64(size)
        }
        return validateStorage(forContentSizeBytes: totalSize)
    }
}
