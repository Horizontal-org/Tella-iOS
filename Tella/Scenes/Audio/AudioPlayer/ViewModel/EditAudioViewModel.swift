//
//  EditAudioViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Combine
import Foundation
import AVFoundation
import SwiftUI

class EditAudioViewModel: EditMediaViewModel {
    
    //MARK: - AudioPlayerManager
    private var audioPlayerManager: AudioPlayerManager = AudioPlayerManager()
    
    //MARK: - Private attributes
    private var currentData : Data?
    
    override init(file: VaultFileDB?, fileURL: URL? = nil, rootFile: VaultFileDB?, appModel: MainAppModel,editMedia:EditMediaProtocol) {
        super.init(file: file, fileURL: fileURL, rootFile: rootFile, appModel: appModel, editMedia: editMedia)
        if let currentFile = file {
            self.currentData = appModel.vaultManager.loadFileData(file: currentFile)
            initFileURL()
        }
        headerTitle = LocalizableVault.editAudioTitle.localized
        loadAudio()
        listenToAudioPlayerUpdates()
    }
    
    func initFileURL() {
        if let fileExtension = file?.fileExtension {
            let url = appModel.vaultManager.saveDataToTempFile(data: self.currentData,
                                                               pathExtension: fileExtension)
            self.fileURL = url
        }
    }
    
    func loadAudio() {
        guard let currentData else { return }
        DispatchQueue.main.async {
            self.audioPlayerManager.initPlayer(data: currentData)
            self.timeDuration = self.audioPlayerManager.audioPlayer.duration
            self.generateTimeLabels()
            self.endTime = self.timeDuration
            
        }
    }
    
    override func handlePlayButton() {
        isPlaying.toggle()
        isPlaying ? seekAudio(to: self.currentPosition) : onPause()
    }
    
    override func onPlay() {
        isPlaying = true
        audioPlayerManager.playRecord()
    }
    
    override func onPause() {
        isPlaying = false
        audioPlayerManager.pauseRecord()
    }
    
    override func updateCurrentPosition() {
        onPause()
        currentTime = currentPosition.formattedAsHHMMSS()
    }
    
    private func generateTimeLabels() {
        if timeDuration != 0.0 {
            let kNumberOfLabels = 5 // This is for the sub-times labels
            let interval = timeDuration / TimeInterval(kNumberOfLabels - 1)
            var times: [String] = []
            for i in 0..<kNumberOfLabels {
                let currentTime = TimeInterval(i) * interval
                times.append(currentTime.formattedAsMMSS())
            }
            timeSlots = times
        }
    }
    
    private func listenToAudioPlayerUpdates() {
        self.audioPlayerManager.audioPlayer.currentTime.sink { [self] value in
            self.currentTime = value.formattedAsHHMMSS()
            self.currentPosition  = Double(value)
            
            if Double(value) >= self.endTime {
                seekAudio(to: startTime, shouldPlay: false )
            }
            
        }.store(in: &self.cancellables)
        
        self.audioPlayerManager.audioPlayer.audioPlayerDidFinishPlaying.sink { [self] value in
            isPlaying = false
        }.store(in: &self.cancellables)
    }
    
    private func seekAudio(to position: Double, shouldPlay: Bool = true) {
        audioPlayerManager.audioPlayer.seekAudio(to: position)
        shouldPlay ? onPlay() : onPause()
    }
}
