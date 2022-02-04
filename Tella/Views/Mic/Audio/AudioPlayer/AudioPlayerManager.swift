//
//  AudioPlayerManager.swift
//  Tella
//
//  Created by Amine Info on 4/2/2022.
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import AVFoundation

protocol AudioManager {

    func initPlayer()
    func playRecord()
    func stopRecord()
    
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
    
    func stopRecord() {
        self.audioPlayer.stopPlayback()
    }
    
    func fastForwardRecord() {
        self.audioPlayer.fastForwardRecord()
    }
    
    func rewindBackRecord() {
        self.audioPlayer.rewindBackRecord()

    }

    

    
}
