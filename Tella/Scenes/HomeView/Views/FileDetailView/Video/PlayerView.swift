//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import AVFoundation
import UIKit

final class VideoPlayerView: UIView {
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    var player: AVPlayer? {
        get {
            playerLayer.player
        }
        set {
            playerLayer.videoGravity = .resizeAspect
            playerLayer.player = newValue
        }
    }
    
    // Function to apply rotation to the video layer
    func rotateVideo(by angle: Int) {
        let radians = angle.degreesToRadians
        playerLayer.setAffineTransform(CGAffineTransform(rotationAngle: radians))
    }
}
