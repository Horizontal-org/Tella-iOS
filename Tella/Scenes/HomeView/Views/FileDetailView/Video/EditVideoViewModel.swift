//
//  EditVideoViewModel.swift
//  Tella
//
//  Created by RIMA on 11.11.24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import AVFoundation

class EditVideoViewModel: EditMediaViewModel {
    private var timeObserver: Any?
    
    let player = AVPlayer()
    
    @Published var thumbnails: [UIImage] = []
    
    var isSeekInProgress = false {
        didSet {
            self.onPause()
        }
    }
    
    override init(file: VaultFileDB?, rootFile: VaultFileDB?, appModel: MainAppModel, shouldReloadVaultFiles: Binding<Bool>) {
        super.init(file: file, rootFile: rootFile, appModel: appModel, shouldReloadVaultFiles: shouldReloadVaultFiles)
        setupListeners()
        initVideo()
    }
    
    private func initVideo() {
        guard let file else { return }
        guard let fileURL = self.appModel.vaultManager.loadVaultFileToURL(file: file)  else {return}
        self.thumbnails = fileURL.generateThumbnails()
        let playerItem = AVPlayerItem(url:fileURL)
        self.player.replaceCurrentItem(with: playerItem)
     }
    override func handlePlayButton() {
        isPlaying.toggle()
        isPlaying ? seekVideo(to: currentPosition) : onPause()
    }
    
    private func setupListeners() {
//        $shouldSeekMedia
//            .dropFirst()
//            .filter({ $0 == false })
//            .sink(receiveValue: { [weak self] _ in
//                guard let self = self else { return }
//                print("should seek media is triggered", shouldSeekMedia)
//                if isDurationHasChanged() {
//                    seekVideo(to: self.currentPosition)
//                }
//            })
//            .store(in: &cancellables)
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
            guard let self = self else { return }
            if self.isSeekInProgress == false {
                 self.currentPosition = time.seconds
                 if time.seconds >= endTime {
                     seekVideo(to: startTime, and: false)
                }
            }
        }
    }
    private func seekVideo(to position: Double, and shouldPlay: Bool = true) {
        
        self.isSeekInProgress = true
        self.currentPosition = position
        
        let targetTime = CMTime(seconds: self.currentPosition ,
                                preferredTimescale: 600)
        self.player.seek(to: targetTime) { _ in
            self.isSeekInProgress = false
            if shouldPlay {
                self.onPlay()
            }
        }
    }
    override func didReachSliderLimit() {
        onPause()
        currentPosition = startTime
    }
    override func onPlay() {
        isPlaying = true
        player.play()
    }
    
    override func onPause() {
        isPlaying = false
        player.pause()
    }
}
