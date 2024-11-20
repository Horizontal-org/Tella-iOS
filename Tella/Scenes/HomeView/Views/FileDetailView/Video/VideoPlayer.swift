//
//  Copyright © 2022 INTERNEWS. All rights reserved.
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
