//
//  AVPlayerItem+.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 30/4/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import AVFoundation
import UIKit

extension AVPlayerItem {
    /// Asynchronously fetches and scales the video's natural size
    func scaledVideoSize(horizontalPadding: CGFloat = 50) async -> CGSize? {
        await withCheckedContinuation { continuation in
            asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
                var error: NSError?
                let status = self.asset.statusOfValue(forKey: "tracks", error: &error)
                if status == .loaded,
                   let track = self.asset.tracks(withMediaType: .video).first {
                    
                    let scaledSize = self.scaledSizeForTrack(track, horizontalPadding: horizontalPadding)
                    continuation.resume(returning: scaledSize)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    /// Calculates the transformed and scaled video size.
    private func scaledSizeForTrack(_ track: AVAssetTrack, horizontalPadding: CGFloat) -> CGSize {
        let transformedSize = track.naturalSize.applying(track.preferredTransform)
        var width = abs(transformedSize.width)
        var height = abs(transformedSize.height)

        let screenWidth = UIScreen.screenWidth - horizontalPadding
        if width > 0, width > screenWidth {
            let scaleFactor = screenWidth / width
            width *= scaleFactor
            height *= scaleFactor
        }
        
        return CGSize(width: width, height: height)
    }
}
