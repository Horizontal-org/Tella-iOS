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
    
    @Published var currentPosition: Double = .zero
    @Published var shouldSeekVideo = false
    @Published var thumbnails: [UIImage] = []
    
    
    var isSeekInProgress = false {
        didSet {
            self.onPause()
        }
    }
    
    init(file: VaultFileDB?, rootFile: VaultFileDB?, appModel: MainAppModel, shouldReloadVaultFiles: Binding<Bool>, playerVM: PlayerViewModel) {
        super.init(file: file, rootFile: rootFile, appModel: appModel, shouldReloadVaultFiles: shouldReloadVaultFiles)
        setupListeners()
        initVideo()
    }
    
    private func initVideo() {
        guard let file else { return }
        guard let fileURL = self.appModel.vaultManager.loadVaultFileToURL(file: file)  else {return}
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
                    seekVideo(to: 0.0)
                }
            }
        }
    }
    private func seekVideo(to position: Double) {
        
        self.isSeekInProgress = true
        self.currentPosition = position
        
        let targetTime = CMTime(seconds: self.currentPosition ,
                                preferredTimescale: 600)
        self.player.seek(to: targetTime) { _ in
            self.isSeekInProgress = false
            self.onPlay()
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
    
    override func trim() {
        Task {
            do {
                let copyName = file?.getCopyName(from: appModel.vaultFilesManager) ?? ""
                guard let trimmedVideoUrl = try await fileURL?.trimMedia(newName: "\(copyName).mov", startTime: startTime, endTime: endTime, type: .mov) else { return }
                self.addEditedFile(urlFile: trimmedVideoUrl)
            } catch {
                self.trimState = .error(error.localizedDescription)
            }
        }
    }
    
    func generateThumbnails()  {
        let count = 10.0
        guard let videoURL = self.fileURL else {
            return
        }
        
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var images: [UIImage] = []
        let duration = asset.duration.seconds
        let interval = duration / count
        
        for i in 0..<Int(count) {
            let time = CMTime(seconds: interval * Double(i), preferredTimescale: 600)
            do {
                let cgImage = try  imageGenerator.copyCGImage(at: time, actualTime: nil)
                images.append(UIImage(cgImage: cgImage))
            } catch {
                debugLog("Error while creating thumbnails")
            }
        }
         self.thumbnails =  images
    }
    
}
