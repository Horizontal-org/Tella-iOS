//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import AVFoundation

protocol AudioManager {
    
    func initPlayer()
    func playRecord()
    func pauseRecord()
    
    func fastForwardRecord()
    func rewindBackRecord()
    
}

class AudioPlayerManager: AudioManager {
    
    var audioPlayer = AudioPlayer()
    
    var currentAudioData: Data?
    
    func initPlayer()    {
        guard
            let audioData = self.currentAudioData
        else { return }
        
        self.audioPlayer.initPlayer(audio: audioData)
    }
    
    func playRecord() {
        
        self.audioPlayer.startPlaying()
        
    }
    func pauseRecord() {
        self.audioPlayer.pausePlayback()
    }
    
    func stopRecord() {
        self.audioPlayer.pausePlayback()
    }
    
    func fastForwardRecord() {
        self.audioPlayer.fastForwardRecord()
    }
    
    func rewindBackRecord() {
        self.audioPlayer.rewindBackRecord()
    }
}
