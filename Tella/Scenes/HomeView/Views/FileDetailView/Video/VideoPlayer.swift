//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import Combine
import AVKit

struct CustomVideoPlayer: UIViewRepresentable {
    
    var player: AVPlayer
    @Binding var rotationAngle: Int // Use this to bind rotation angle
    
    func makeUIView(context: Context) -> VideoPlayerView {
        let view = VideoPlayerView()
        view.player = player
        return view
    }
    
    func updateUIView(_ uiView: VideoPlayerView, context: Context) {
        // Update the rotation of the video when the angle changes
        uiView.rotateVideo(by: rotationAngle)
    }
}
