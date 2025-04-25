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
    
    @Published var currentPosition: Double = .zero
    @Published var shouldSeekVideo = false
    @Published var thumbnails: [UIImage] = []
    @Published var rotationAngle: CGFloat = 0
    
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
        self.onPlay()
    }
    
    private func setupListeners() {
        $shouldSeekVideo
            .dropFirst()
            .filter({ $0 == false })
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                seekVideo(to: self.currentPosition)
            })
            .store(in: &cancellables)
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
            guard let self = self else { return }
            if self.isSeekInProgress == false {
                
                self.currentPosition = time.seconds
                self.updateOffset(time: currentPosition)
                
                if time.seconds == self.file?.duration {
                    seekVideo(to: 0.0, and: false)
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
    
    override func onPlay() {
        isPlaying = true
        player.play()
    }
    
    override func onPause() {
        isPlaying = false
        player.pause()
    }
    
    func rotate() {
        Task { @MainActor in
            do {
                let copyName = file?.getCopyName(from: appModel.vaultFilesManager) ?? ""
                guard let rotatedVideoUrl = try await fileURL?.rotateVideo(by: -3 * .pi / 2 )   else { return }
                self.addEditedFile(urlFile: rotatedVideoUrl)
            } catch {
                self.trimState = .error(error.localizedDescription)
            }
        }
    }
}
