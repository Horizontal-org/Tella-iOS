//
//  RotateVideoURLExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 28/4/2025.
//  Copyright © 2025 HORIZONTAL.  
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import AVFoundation

extension URL {
    
    /// Rotates a video by the given angle and saves it with a new name.
    /// - Parameters:
    ///   - angle: The rotation angle in degrees.
    ///   - newName: The desired new file name (without extension).
    /// - Returns: URL to the newly rotated video.
    
    func rotateVideo(by angle: Int, newName: String) async throws -> URL {
        // Convert the angle to radians
        let asset = AVAsset(url: self)
        let angleInRadians = angle.degreesToRadians
        
        // Get the video track from the asset
        guard let videoTrack = try getVideoTrack(from: asset) else {
            throw RuntimeError(LocalizableError.commonError.localized)
        }
        
        // Create the composition and add the video track
        let composition = try createComposition(for: asset, videoTrack: videoTrack)
        
        // Add audio track if available
        try addAudioTrack(to: composition, from: asset)
        
        // Create the rotation transform and render size based on the angle
        let (rotationTransform, renderSize) = try createRotationTransform(for: videoTrack, angle: angleInRadians)
        
        // Create the video composition with the necessary transformations
        let videoComposition = try createVideoComposition(with: composition, rotationTransform: rotationTransform, renderSize: renderSize, assetDuration: asset.duration)
        
        // Export the rotated video
        return try await exportVideo(from: composition, videoComposition: videoComposition, newName: newName)
    }

    // Function to retrieve the video track from the AVAsset
    func getVideoTrack(from asset: AVAsset) throws -> AVAssetTrack? {
        // Check if the asset contains a video track
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            debugLog("No video track")
            return nil // Return nil if no video track is found
        }
        return videoTrack
    }

    // Function to create a composition and add the video track
    func createComposition(for asset: AVAsset, videoTrack: AVAssetTrack) throws -> AVMutableComposition {
        let composition = AVMutableComposition()
        
        // Add the video track to the composition
        guard let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            debugLog("Failed to create composition video track")
            throw RuntimeError(LocalizableError.commonError.localized) // Throw error if track cannot be added
        }
        
        // Insert the video track's time range into the composition
        try compositionVideoTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: asset.duration),
            of: videoTrack,
            at: .zero
        )
        return composition
    }

    // Function to add an audio track to the composition, if available
    func addAudioTrack(to composition: AVMutableComposition, from asset: AVAsset) throws {
        // Check if the asset contains an audio track
        if let audioTrack = asset.tracks(withMediaType: .audio).first,
           let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
            // Add the audio track's time range to the composition
            try compositionAudioTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: asset.duration),
                of: audioTrack,
                at: .zero
            )
        }
    }

    // Function to create the rotation transform and render size based on the angle
    func createRotationTransform(for videoTrack: AVAssetTrack, angle: CGFloat) throws -> (CGAffineTransform, CGSize) {
        let originalTransform = videoTrack.preferredTransform
        let videoSize = videoTrack.naturalSize.applying(originalTransform)
        
        let absWidth = abs(videoSize.width)
        let absHeight = abs(videoSize.height)
        
        var rotationTransform: CGAffineTransform
        var renderSize: CGSize
        
        // Apply the appropriate rotation and calculate the render size
        switch angle {
        case 0:
            rotationTransform = originalTransform
            renderSize = CGSize(width: absWidth, height: absHeight)
            
        case .pi / 2, -3 * .pi / 2:
            rotationTransform = originalTransform.concatenating(
                CGAffineTransform(translationX: absHeight, y: 0).rotated(by: angle)
            )
            renderSize = CGSize(width: absHeight, height: absWidth)
            
        case .pi, -.pi:
            rotationTransform = originalTransform.concatenating(
                CGAffineTransform(translationX: absWidth, y: absHeight).rotated(by: angle)
            )
            renderSize = CGSize(width: absWidth, height: absHeight)
            
        case 3 * .pi / 2, -.pi / 2:
            rotationTransform = originalTransform.concatenating(
                CGAffineTransform(translationX: 0, y: absWidth).rotated(by: angle)
            )
            renderSize = CGSize(width: absHeight, height: absWidth)
            
        default:
            debugLog("Unsupported angle: \(angle)")
            throw RuntimeError(LocalizableError.commonError.localized) // Throw error if angle is unsupported
        }
        
        return (rotationTransform, renderSize)
    }

    // Function to create the video composition with rotation and render size
    func createVideoComposition(with composition: AVMutableComposition, rotationTransform: CGAffineTransform, renderSize: CGSize, assetDuration: CMTime) throws -> AVMutableVideoComposition {
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.renderSize = renderSize
        
        // Create the video composition instruction
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: assetDuration)
        
        // Create the layer instruction for applying the rotation transform
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: composition.tracks(withMediaType: .video).first!)
        layerInstruction.setTransform(rotationTransform, at: .zero)
        
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        return videoComposition
    }

    // Function to export the video with the applied rotation and save it to the specified URL
    func exportVideo(from composition: AVMutableComposition, videoComposition: AVMutableVideoComposition, newName: String) async throws -> URL {
        let outputURL = createURL(name: "\(newName).\(self.pathExtension.lowercased())")
        try? FileManager.default.removeItem(at: outputURL) // Remove any existing file at the output URL
        
        // Create the export session
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            debugLog("Failed to create export session")
            throw RuntimeError(LocalizableError.commonError.localized) // Throw error if export session cannot be created
        }
        
        // Set the export session properties
        exportSession.videoComposition = videoComposition
        exportSession.outputURL = outputURL
        exportSession.outputFileType = self.getAVFileType()
        exportSession.shouldOptimizeForNetworkUse = true
        
        // Perform the export asynchronously
        await exportSession.export()
        
        // Handle the export session result
        switch exportSession.status {
        case .completed:
            return outputURL // Return the output URL if export is successful
        case .failed:
            debugLog("Export failed")
            throw RuntimeError(LocalizableError.commonError.localized) // Throw error if export fails
        default:
            debugLog("Export incomplete")
            throw RuntimeError(LocalizableError.commonError.localized) // Handle incomplete export
        }
    }
}
