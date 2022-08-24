//
//  Copyright © 2022 INTERNEWS. All rights reserved.
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
    
    var videoSize: CGSize? {
        didSet {
            DispatchQueue.main.async {

                if let videoSize = self.videoSize {
                if videoSize.width < videoSize.height {
                    self.playerLayer.videoGravity = .resizeAspectFill
                    
                } else {
                    self.playerLayer.videoGravity = .resizeAspect
                }
            }
        }
        }
    }
}
