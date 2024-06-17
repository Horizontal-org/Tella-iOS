//
//  PHAssetExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 17/6/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {
    
    /// An extension on `PHAsset` to asynchronously fetch image data.
    ///
    /// This function uses Swift's concurrency features to provide an async/await interface for fetching image data
    /// from a `PHAsset` object.
    ///
    /// - Returns: The image data as a `Data` object, or nil if no data is available.
    /// - Throws: An error if the image data could not be fetched.
    ///
    
    func getDataFromAsset() async throws -> Data? {
        
        return try await withCheckedThrowingContinuation { continuation in
            
            PHImageManager.default().requestImageDataAndOrientation(for: self, options: nil) { (data, uti, orientation, info) in
                
                guard let data else {
                    guard let error = info?[PHImageErrorKey] as? Error else {
                        continuation.resume(throwing: RuntimeError("Unknown error occurred"))
                        return
                    }
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: data)
            }
        }
    }
    
    /// An extension on `PHAsset` to asynchronously fetch the URL of an `AVAsset`.
    ///
    /// This function uses Swift's concurrency features to provide an async/await interface for fetching the URL
    /// of an `AVAsset` from a `PHAsset` object.
    ///
    /// - Returns: The URL of the `AVAsset` as a `URL` object, or nil if no URL is available.
    /// - Throws: An error if the URL could not be fetched.
    
    func getAVAssetUrl() async throws -> URL? {
        
        return try await withCheckedThrowingContinuation { continuation in
            
            PHImageManager.default().requestAVAsset(forVideo: self, options: nil) { avAsset, audioMix, info in
                
                guard let url = (avAsset as? AVURLAsset)?.url else {
                    guard let error = info?[PHImageErrorKey] as? Error else {
                        continuation.resume(throwing: RuntimeError("Unknown error occurred"))
                        return
                    }
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: url)
            }
        }
    }
    
    /// An extension on `PHAsset` to fetch the first `PHAssetResource`.
    ///
    /// This function retrieves the first `PHAssetResource` associated with the `PHAsset`.
    /// The `PHAssetResource` provides more detailed information about the asset's resources.
    ///
    /// - Returns: The first `PHAssetResource` if available, otherwise nil.
    
    func getAssetResource() -> PHAssetResource? {
        return PHAssetResource.assetResources(for: self).first
    }
}


