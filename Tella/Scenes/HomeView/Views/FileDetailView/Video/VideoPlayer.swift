//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine
import AVKit

struct CustomVideoPlayer: UIViewRepresentable {
    
    @ObservedObject var playerVM: PlayerViewModel
    
    func makeUIView(context: Context) -> VideoPlayerView {
        let view = VideoPlayerView()
        view.player = playerVM.player
        return view
    }
    
    func updateUIView(_ uiView: VideoPlayerView, context: Context) { }
}
