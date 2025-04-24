//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import Combine
import AVKit

struct CustomVideoPlayer: UIViewRepresentable {
    
    var player: AVPlayer

    func makeUIView(context: Context) -> VideoPlayerView {
        let view = VideoPlayerView()
        view.player = player
        return view
    }
    
    func updateUIView(_ uiView: VideoPlayerView, context: Context) {
    }
}
