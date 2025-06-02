//
//  PHAssetExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 17/6/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Photos
import UIKit

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
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: RuntimeError("Unknown error occurred"))
                }
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
                
                if let url = (avAsset as? AVURLAsset)?.url {
                    continuation.resume(returning: url)
                } else if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: RuntimeError("Unknown error occurred"))
                }
            }
        }
    }
    
    func getAVAsset() async throws -> AVAsset? {
        
        return try await withCheckedThrowingContinuation { continuation in
            
            PHImageManager.default().requestAVAsset(forVideo: self, options: nil) { avAsset, audioMix, info in
                
                if let avAsset = (avAsset ) {
                    continuation.resume(returning: avAsset)
                } else if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: RuntimeError("Unknown error occurred"))
                }
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
    
    func getImageFromAsset() -> UIImage {
        let manager = PHImageManager.default()
        var image = UIImage()
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        manager.requestImage(for: self, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: options) { img, info in
            if let img = img {
                image = img
            }
        }
        return image
    }
}
