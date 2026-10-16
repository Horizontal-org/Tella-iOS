//
//  AVCapturePhotoExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 8/1/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import AVFoundation
import ImageIO
import UniformTypeIdentifiers

extension AVCapturePhoto {
    
    func saveImage(to url: URL,
                   shouldPreserveMetadata: Bool,
                   aspectRatio: CGFloat) throws {
        guard let cgImage = self.cgImageRepresentation() else {
            debugLog("Failed to get CGImage from photo.")
            throw CocoaError(.fileWriteUnknown)
        }
        
        let croppedImage = CameraAspectRatio.cropped(cgImage,
                                                     orientation: cgImageOrientation,
                                                     portraitAspectRatio: aspectRatio)
        
        var metadata : [String:Any] = [:]
        
        if shouldPreserveMetadata {
            metadata = self.metadata
            metadata[kCGImagePropertyPixelWidth as String] = croppedImage.width
            metadata[kCGImagePropertyPixelHeight as String] = croppedImage.height
            metadata[kCGImagePropertyOrientation as String] = CGImagePropertyOrientation.up.rawValue
        }  else {
            metadata[kCGImagePropertyOrientation as String] = CGImagePropertyOrientation.up.rawValue
        }
        
        let imageData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(imageData as CFMutableData,
                                                                 UTType.heic.identifier as CFString,
                                                                 1, nil) else {
            debugLog("Failed to create image destination.")
            throw CocoaError(.fileWriteUnknown)
        }
        
        CGImageDestinationAddImage(destination, croppedImage, metadata as CFDictionary)
        
        guard CGImageDestinationFinalize(destination) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try (imageData as Data).write(to: url)
    }
    
    private var cgImageOrientation: CGImagePropertyOrientation {
        if let number = metadata[kCGImagePropertyOrientation as String] as? NSNumber,
           let orientation = CGImagePropertyOrientation(rawValue: number.uint32Value) {
            return orientation
        }
        return .up
    }
    
}
