//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine


class AudioPlayerViewModel: ObservableObject {
    
    @Published var isPlaying = false
    
    @Published var shouldDisableFastForwardButton : Bool = false
    @Published var shouldDisableRewindBackButton : Bool = false
    
    @Published var currentTime : String  = "00:00:00"
    @Published var duration : String  = "00:00:00"
    
    var cancellable: Set<AnyCancellable> = []
    var currentFile: VaultFileDB?
    var audioPlayerManager: AudioPlayerManager = AudioPlayerManager()
    
    var currentData : Data?
    
    @Published var audioIsReady = false
    init(currentData: Data?) {
        self.currentData = currentData
        listenToAudioPlayerUpdates()
        loadAudio()
    }
    
    private func listenToAudioPlayerUpdates() {
        audioPlayerManager.audioPlayer.currentTime.sink { value in
            self.currentTime = value.formattedAsHHMMSS()
        }.store(in: &self.cancellable)
        
        audioPlayerManager.audioPlayer.audioPlayerDidFinishPlaying.sink { [self] value in
            self.onPausePlaying()
        }.store(in: &self.cancellable)
    }
    func loadAudio() {
        
        guard let currentData else { return }
        
        DispatchQueue.main.async {
            self.audioPlayerManager.initPlayer(data: currentData)
            self.duration = self.audioPlayerManager.audioPlayer.duration.formattedAsHHMMSS()
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
