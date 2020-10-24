//
//  VideoPlayerUI.swift
//  Tella
//
//  Created by Abhishek Dave on 24/10/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI
import AVKit


struct PlayerView: UIViewRepresentable {
    
  let data: Data
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
  }

  func makeUIView(context: Context) -> UIView {
    let videoPlayer = VideoPlayerUI(videoData: data)
    videoPlayer.videoData = data
    return videoPlayer
  }
}

class VideoPlayerUI: UIView {
  private let playerLayer = AVPlayerLayer()
    
  var videoData: Data?
    
    init(videoData: Data) {
        super.init(frame: .zero)
        let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("video").appendingPathExtension("mp4")
        let wasFileWritten = (try? videoData.write(to: tmpFileURL, options: [.atomic])) != nil

        if !wasFileWritten{
            print("File was NOT Written")
        }
        let player = AVPlayer(url: tmpFileURL)
        player.play()
        
        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }

  required init?(coder: NSCoder) {
     fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    playerLayer.frame = bounds
  }
}
