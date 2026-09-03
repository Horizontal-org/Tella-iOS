//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import AVFoundation

struct CustomVideoPlayer: UIViewRepresentable {
    
    var player: AVPlayer
    @Binding var rotationAngle: Int
    var isZoomEnabled: Bool = false
    
    func makeUIView(context _: Context) -> ZoomableMediaView {
        let playerView = VideoPlayerView()
        playerView.player = player
        
        let container = ZoomableMediaView(mediaView: playerView)
        container.isZoomEnabled = isZoomEnabled
        return container
    }
    
    func updateUIView(_ uiView: ZoomableMediaView, context _: Context) {
        guard let playerView = uiView.mediaView as? VideoPlayerView else { return }
        
        if playerView.player !== player {
            playerView.player = player
        }
        if !isZoomEnabled {
            playerView.rotateVideo(by: rotationAngle)
        }
        uiView.isZoomEnabled = isZoomEnabled
    }
}
