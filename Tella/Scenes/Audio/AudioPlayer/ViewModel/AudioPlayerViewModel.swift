//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

enum PlayState {
    case ready
    case playing
}

class AudioPlayerViewModel: ObservableObject {
    
    @Published var state: PlayState = .ready
    
    @Published var shouldDisableFastForwardButton : Bool = false
    @Published var shouldDisableRewindBackButton : Bool = false

    @Published var currentTime : String  = "00:00:00"
    @Published var duration : String  = "00:00:00"

    private var cancellable: Set<AnyCancellable> = []

    var audioPlayerManager: AudioPlayerManager = AudioPlayerManager()
    
     var currentData : Data?
  
    @Published var audioIsReady = false

    init(currentData: Data?) {
         self.currentData = currentData

        audioPlayerManager.audioPlayer.currentTime.sink { value in
            self.currentTime = value.stringFromTimeInterval()
        }.store(in: &self.cancellable)
        
        audioPlayerManager.audioPlayer.duration.sink { value in
            self.duration = value.stringFromTimeInterval()
        }.store(in: &self.cancellable)
        
        audioPlayerManager.audioPlayer.audioPlayerDidFinishPlaying.sink { [self] value in
            self.state = .ready
            
            self.shouldDisableFastForwardButton = true
            self.shouldDisableRewindBackButton = true


            self.updateView()

            
        }.store(in: &self.cancellable)
        
        loadAudio()
    }
    
    func loadAudio() {

        guard let currentData else { return }
        
        DispatchQueue.main.async {
            self.audioPlayerManager.currentAudioData = currentData
            self.audioPlayerManager.initPlayer()
        }
    }

    
    func onStartPlaying() {
        
        self.state = .playing
        
        self.audioPlayerManager.playRecord()
        
        shouldDisableFastForwardButton = false
        shouldDisableRewindBackButton = false

        self.updateView()
    }
    
    func onPausePlaying() {
        self.state = .ready
        
        self.audioPlayerManager.pauseRecord()
        
        shouldDisableFastForwardButton = true
        shouldDisableRewindBackButton = true


        self.updateView()
    }
    
    func onStopPlaying() {

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
