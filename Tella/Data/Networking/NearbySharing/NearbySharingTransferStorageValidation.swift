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
    
    // Extra bytes beyond the declared payload
    private static let diskSafetyMarginBytes: Int64 = 10 * 1024 * 1024
    
    // Use 2 for a temp copy + payload size
    private static let declaredContentDiskMultiplier: Int64 = 2
    
    // MARK: - Single file (recipient upload)
    
    // Requires 2 × declaredSize + margin free space : temp + finalize behavior for one file
    static func validateStorage(forContentSizeBytes declaredSize: Int64) -> ServerStatus? {
        let requiredSpace = (declaredSize * declaredContentDiskMultiplier) + diskSafetyMarginBytes
        guard FileManager.default.availableDiskSpace >= requiredSpace else {
            return ServerStatus(code: .insufficientStorage, message: .insufficientStorage)
        }
        return nil
    }
    
    // MARK: - Prepare upload (recipient)
    
    static func validateStorageAgainstLocalDisk(_ files: [NearbySharingFile]?) -> ServerStatus? {
        guard let files, !files.isEmpty else { return nil }
        var totalDeclared: Int64 = 0
        var maxDeclared: Int64 = 0
        for file in files {
            guard let size = file.size, size >= 0 else {
                return ServerStatus(code: .badRequest, message: .invalidRequestFormat)
            }
            let s = Int64(size)
            totalDeclared += s
            maxDeclared = max(maxDeclared, s)
        }
        let requiredSpace = totalDeclared + maxDeclared + diskSafetyMarginBytes
        guard FileManager.default.availableDiskSpace >= requiredSpace else {
            return ServerStatus(code: .insufficientStorage, message: .insufficientStorage)
        }
        return nil
    }
}
