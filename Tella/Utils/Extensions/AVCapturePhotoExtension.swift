//
//  AVCapturePhotoExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 8/1/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import AVFoundation

extension AVCapturePhoto {
    
    func saveImage(to url: URL, shouldPreserveMetadata:Bool) -> Bool {
        // Safely get the CGImage representation
        guard let cgImage = self.cgImageRepresentation() else {
            debugLog("Failed to get CGImage from photo.")
            return false
        }
        
        var metadata : [String:Any] = [:]
        
        if shouldPreserveMetadata {
            // Get the photo metadata
            metadata = self.metadata
        }  else {
            let orientationValue = self.metadata[kCGImagePropertyOrientation as String]
            metadata[kCGImagePropertyOrientation as String] = orientationValue
        }
        
        // Prepare the image destination
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.heic.identifier as CFString, 1, nil) else {
            debugLog("Failed to create image destination.")
            return false
        }
        
        // Add the CGImage with metadata to the destination
        CGImageDestinationAddImage(destination, cgImage, metadata as CFDictionary)
        
        return CGImageDestinationFinalize(destination)
    }
    
}
