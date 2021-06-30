//
//  VideoViewer.swift
//  Tella
//
//  Created by Ahlem on 30/06/2021.
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import AVKit


struct VideoViewer: View {
    var videoURL: URL?
    
    var body: some View {
        if let url = videoURL {
            if #available(iOS 14.0, *) {
                VideoPlayer(player: AVPlayer(url: url))
            } else {
                VideoPlayerController(videoURL: url)
            }
        } else {
            Text("Video URL not available!")
        }
        
    }
}

struct VideoViewer_Previews: PreviewProvider {
    static var previews: some View {
        VideoViewer()
    }
}
