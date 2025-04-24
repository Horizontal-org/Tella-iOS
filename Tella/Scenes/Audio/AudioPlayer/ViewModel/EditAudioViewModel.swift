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
    
    override init(file: VaultFileDB?, rootFile: VaultFileDB?, appModel: MainAppModel, shouldReloadVaultFiles: Binding<Bool>) {
        super.init(file: file, rootFile: rootFile, appModel: appModel, shouldReloadVaultFiles: shouldReloadVaultFiles)
        if let currentFile = file {
            self.currentData = appModel.vaultManager.loadFileData(file: currentFile)
        }
        headerTitle = LocalizableVault.editAudioTitle.localized
        loadAudio()
        listenToAudioPlayerUpdates()
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
    
    private func listenToAudioPlayerUpdates() {
        self.audioPlayerManager.audioPlayer.currentTime.sink { value in
            self.currentTime = value.formattedAsHHMMSS()
            self.updateOffset(time: Double(value) )
        }.store(in: &self.cancellables)
        
        self.audioPlayerManager.audioPlayer.audioPlayerDidFinishPlaying.sink { [self] value in
            isPlaying = false
        }.store(in: &self.cancellables)
    }
    
    override func onPlay() {
        audioPlayerManager.playRecord()
    }
    
    override func onPause() {
        audioPlayerManager.pauseRecord()
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
    
}
