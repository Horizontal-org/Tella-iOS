//
//  AudioPlayer.swift
//  Tella
//
//  Created by Erin Simshauser on 5/8/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

/*
 This class is used to play and pause audio files for previewing functionality. It uses the AVAudioPlayer framework and slightly adapts it so that we can pass in data from the Preview file to be played.
 */

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
        // the category of playback allows for sound to be played over iPhone speakers, even when the phone is in silent mode
            try playbackSession.setCategory(.playback)
        } catch let error{
            print(error.localizedDescription)
        }

        do {
        //  the audioplayer is initialized using data rather than a url since decrypting files only gives data
        //  this allows a user to listen to files in a secure way
            audioPlayer = try AVAudioPlayer.init(data: audio)
            audioPlayer.delegate = self
            audioPlayer.play()
            playStatus = true
        } catch {
            print("Playback failed.")
        }
    }

//  pauses the playback
    func stopPlayback() {
        audioPlayer.pause()
        playStatus = false
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            playStatus = false
        }
    }
    
//  not implemented yet, but could be used in a UI implementation where a play or pause button is displayed based on the status of the audiio player
    func isPlaying() -> Bool {
        return playStatus
    }

}
