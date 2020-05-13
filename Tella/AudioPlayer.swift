//
//  AudioPlayer.swift
//  Tella
//
//  Created by Erin Simshauser on 5/8/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class AudioPlayer: NSObject, AVAudioPlayerDelegate {

    var playStatus = false
    var audioPlayer: AVAudioPlayer!

    func startPlayback (audio: Data) {

        let playbackSession = AVAudioSession.sharedInstance()

        do {
            try playbackSession.setCategory(.playback)
        } catch let error{
            print(error.localizedDescription)
        }

        do {
            audioPlayer = try AVAudioPlayer.init(data: audio)
            audioPlayer.delegate = self
            if(audioPlayer.play()) {
            }
            playStatus = true
        } catch {
            print("Playback failed.")
        }
    }

    func stopPlayback() {
        audioPlayer.pause()
        playStatus = false
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            playStatus = false
        }
    }
    
    func isPlaying() -> Bool {
        return playStatus
    }

}
