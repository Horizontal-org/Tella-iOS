//
//  VideoPlayerController.swift
//  Tella
//
//  Created by Ahlem on 30/06/2021.
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import AVKit

struct VideoPlayerController: UIViewControllerRepresentable {
    typealias UIViewControllerType = AVPlayerViewController
    
    var videoURL: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
    
}
