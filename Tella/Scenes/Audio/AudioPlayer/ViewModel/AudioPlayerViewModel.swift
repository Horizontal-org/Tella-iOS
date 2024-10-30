//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine


class AudioPlayerViewModel: ObservableObject {
    
    @Published var isPlaying = false
    
    @Published var shouldDisableFastForwardButton : Bool = false
    @Published var shouldDisableRewindBackButton : Bool = false
    
    @Published var currentTime : String  = "00:00:00"
    @Published var duration : String  = "00:00:00"
    
    var mainAppModel: MainAppModel
    var cancellable: Set<AnyCancellable> = []
    var currentFile: VaultFileDB?
    var audioPlayerManager: AudioPlayerManager = AudioPlayerManager()
    
    var currentData : Data?
    
    @Published var audioIsReady = false
    
    @Published var timeDuration: TimeInterval?
    
    init(currentFile: VaultFileDB?, mainAppModel: MainAppModel) {
        self.currentFile = currentFile
        self.mainAppModel = mainAppModel
        if let currentFile {
            self.currentData = self.mainAppModel.vaultManager.loadFileData(file: currentFile)
        }
        listenToAudioPlayerUpdates()
        loadAudio()
    }
    
    private func listenToAudioPlayerUpdates() {
        audioPlayerManager.audioPlayer.currentTime.sink { value in
            self.currentTime = value.formattedAsHHMMSS()
        }.store(in: &self.cancellable)
        
        audioPlayerManager.audioPlayer.duration.sink { value in
            self.duration = value.formattedAsHHMMSS()
            self.timeDuration = value
        }.store(in: &self.cancellable)
        
        audioPlayerManager.audioPlayer.audioPlayerDidFinishPlaying.sink { [self] value in
            self.onPausePlaying()
        }.store(in: &self.cancellable)
    }
    func loadAudio() {
        
        guard let currentData else { return }
        
        DispatchQueue.main.async {
            self.audioPlayerManager.currentAudioData = currentData
            self.audioPlayerManager.initPlayer()
        }
    }
    
    func onStartPlaying() {
        isPlaying = true
        self.audioPlayerManager.playRecord()
        
        shouldDisableFastForwardButton = false
        shouldDisableRewindBackButton = false
        
        self.updateView()
    }
    
    func onPausePlaying() {
        self.isPlaying = false
        shouldDisableFastForwardButton = true
        shouldDisableRewindBackButton = true
        self.updateView()
        self.audioPlayerManager.pauseRecord()
    }
    
    func onStopPlaying() {
        isPlaying = false
        self.audioPlayerManager.stopRecord()
    }
    
    func onFastForward() {
        self.audioPlayerManager.fastForwardRecord()
    }
    
    func onrewindBack() {
        self.audioPlayerManager.rewindBackRecord()
        
    }
    
    fileprivate func updateView() {
        self.objectWillChange.send()
    }
}
