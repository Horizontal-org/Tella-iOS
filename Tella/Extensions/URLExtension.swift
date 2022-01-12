//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//


import AVFoundation

extension URL {
    
    func resolutionForVideo() -> CGSize? {
       guard let track = AVURLAsset(url: self).tracks(withMediaType: AVMediaType.video).first else { return nil }
       return track.naturalSize.applying(track.preferredTransform)
    }
    
    func getDuration() -> Double? {
        let asset = AVAsset(url: self)

        let duration = asset.duration
        return CMTimeGetSeconds(duration)
    }
}
