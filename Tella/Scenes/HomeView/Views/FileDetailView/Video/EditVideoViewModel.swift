//
//  EditVideoViewModel.swift
//  Tella
//
//  Created by RIMA on 11.11.24.
//  Copyright © 2024 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Combine
import Foundation
import SwiftUI
import AVFoundation

class EditVideoViewModel: EditMediaViewModel {
    private var timeObserver: Any?
    
    let player = AVPlayer()
    
    @Published var thumbnails: [UIImage] = []
    @Published var rotationAngle: Int = 0
    @Published var rotateState: ViewModelState<Bool> = .loaded(false)
    @Published var videoSize: CGSize = .zero
    
    var videoPlayerSize : CGSize {
        let angle = abs(Int(rotationAngle)) % 360
        let isRotated = angle == 90 || angle == 270
        let scaleFactor = videoSize.width / videoSize.height
        
        let frameWidth = isRotated ? videoSize.height * scaleFactor : videoSize.width
        let frameHeight = isRotated ? videoSize.width * scaleFactor : videoSize.height
        
        return CGSize(width: frameWidth, height: frameHeight)
    }
    
    var isSeekInProgress = false {
        didSet {
            self.onPause()
        }
    }
    
    override init(file: VaultFileDB?, rootFile: VaultFileDB?, appModel: MainAppModel, editMedia:EditMediaProtocol) {
        super.init(file: file, rootFile: rootFile, appModel: appModel, editMedia: editMedia)
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
        isPlaying ? onPause() : onPlay()
    }
    
    private func setupListeners() {
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: nil) { [weak self] time in
            guard let self = self else { return }
            self.currentPosition = time.seconds
            
            if self.currentPosition >= self.endTime {
                self.onPause()
                self.seekVideo(to: self.startTime, shouldPlay: false)
            }
        }
    }
    
    private func seekVideo(to position: Double, shouldPlay: Bool = false) {
        self.currentPosition = position
        let targetTime = CMTime(seconds: self.currentPosition, preferredTimescale: 600)
        
        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] completed in
            guard let self = self else { return }
            if completed {
                if shouldPlay {
                    self.player.play()
                }
            }
        }
    }
    
    override func didReachSliderLimit() {
        onPause()
        currentPosition = startTime
    }
    
    override func onPlay() {
        if self.currentPosition >= endTime {
            currentPosition = startTime
        }
        
        seekVideo(to: currentPosition, shouldPlay: true)
        isPlaying = true
    }
    
    override func onPause() {
        isPlaying = false
        player.pause()
    }
    
    // Rotates a video file asynchronously and updates UI state accordingly
    func rotate() {
        Task { @MainActor in
            do {
                rotateState = .loading
                let copyName = file?.getCopyName(from: appModel.vaultFilesManager) ?? ""
                guard let rotatedVideoUrl = try await fileURL?.rotateVideo(by: rotationAngle, newName: copyName )   else { return }
                self.addEditedFile(urlFile: rotatedVideoUrl)
                self.rotateState = .loaded(true)
                self.rotateState = .none
            } catch {
                self.rotateState = .error(error.localizedDescription)
            }
        }
    }
    
    // Observes the size of the current video in the player and updates a stored value
    func observeVideoSize() {
        Task { @MainActor in
            guard let currentItem = player.currentItem else { return }
            let horizontalPadding : CGFloat = 50
            let size =   await currentItem.scaledVideoSize(horizontalPadding: horizontalPadding)
            self.videoSize = size ?? .zero
        }
    }
}
