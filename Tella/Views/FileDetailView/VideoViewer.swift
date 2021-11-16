//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import AVKit


struct VideoViewer: View {
    var videoURL: URL?
    @ObservedObject var appModel: MainAppModel

    var body: some View {
        if let url = videoURL {
            if #available(iOS 14.0, *) {
                VideoPlayer(player: AVPlayer(url: url))
                    .onDisappear {
                        appModel.vaultManager.clearTmpDirectory()
                    }

            } else {
                VideoPlayerController(videoURL: url)
            }
        } else {
//            Text("Video URL not available!")
        }
    }
}

struct VideoViewer_Previews: PreviewProvider {
    static var previews: some View {
        VideoViewer(appModel: MainAppModel())
    }
}
