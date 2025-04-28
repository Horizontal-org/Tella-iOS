//
//  RotateVideoURLExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 28/4/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import AVFoundation

extension URL {
    
    /// Rotates a video by the given angle and saves it with a new name.
    /// - Parameters:
    ///   - angle: The rotation angle in degrees.
    ///   - newName: The desired new file name (without extension).
    /// - Returns: URL to the newly rotated video.
    
    func rotateVideo(by angle: Int, newName: String) async throws -> URL {
        let asset = AVAsset(url: self)
        let angle = angle.degreesToRadians
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            debugLog("No video track")
            throw RuntimeError(LocalizableError.commonError.localized)
        }
        
        let composition = AVMutableComposition()
        guard let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            debugLog("Failed to create composition video track")
            throw RuntimeError(LocalizableError.commonError.localized)
        }
        
        try compositionVideoTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: asset.duration),
            of: videoTrack,
            at: .zero
        )
        
        // Add audio if available
        if let audioTrack = asset.tracks(withMediaType: .audio).first,
           let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
            try compositionAudioTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: asset.duration),
                of: audioTrack,
                at: .zero
            )
        }
        
        // Calculate rotation transform
        let originalTransform = videoTrack.preferredTransform
        let videoSize = videoTrack.naturalSize.applying(originalTransform)
        
        let absWidth = abs(videoSize.width)
        let absHeight = abs(videoSize.height)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        var rotationTransform: CGAffineTransform
        var renderSize: CGSize
        
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
            throw RuntimeError(LocalizableError.commonError.localized)
            
        }
        
        videoComposition.renderSize = renderSize
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerInstruction.setTransform(rotationTransform, at: .zero)
        
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        let outputURL = createURL(name: "\(newName).\(self.pathExtension.lowercased())")
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            debugLog("Failed to create export session")
            throw RuntimeError(LocalizableError.commonError.localized)
        }
        
        exportSession.videoComposition = videoComposition
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        exportSession.shouldOptimizeForNetworkUse = true
        
        await exportSession.export()
        
        switch exportSession.status {
        case .completed:
            return outputURL
        case .failed:
            debugLog("Export failed")
            throw RuntimeError(LocalizableError.commonError.localized)
            
        default:
            debugLog("Export incomplete")
            throw RuntimeError(LocalizableError.commonError.localized)
        }
    }
}
