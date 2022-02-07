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

class AudioPlayer: NSObject, AVAudioPlayerDelegate, ObservableObject {
    
    
    var playStatus = false
    var audioPlayer: AVAudioPlayer!
    private var timer = Timer()
    
    @Published var currentTime = CurrentValueSubject<TimeInterval, Never>(0.0)
    @Published var duration = CurrentValueSubject<TimeInterval, Never>(0.0)
    @Published var audioPlayerDidFinishPlaying = CurrentValueSubject<Bool, Never>(false)
    
    
    
    func initPlayer(audio: Data) {
        
        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            // the category of playback allows for sound to be played over iPhone speakers, even when the phone is in silent mode
            try playbackSession.setCategory(.playback)
            try playbackSession.setActive(true)
            
        } catch let error{
            debugLog(error.localizedDescription)
        }
        
        do {
            //  the audioplayer is initialized using data rather than a url since decrypting files only gives data
            //  this allows a user to listen to files in a secure way
            audioPlayer = try AVAudioPlayer.init(data: audio)
            audioPlayer.delegate = self
            
            audioPlayer.currentTime = 0
            
            duration.send(audioPlayer.duration)
            
            initialiseTimerRunning()
        } catch  let error {
            debugLog(error.localizedDescription)
        }
    }
    func startPlayback (audio: Data) {
        
        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            // the category of playback allows for sound to be played over iPhone speakers, even when the phone is in silent mode
            try playbackSession.setCategory(.playback)
            try playbackSession.setActive(true)
            
        } catch let error{
            debugLog(error.localizedDescription)
        }
        
        do {
            //  the audioplayer is initialized using data rather than a url since decrypting files only gives data
            //  this allows a user to listen to files in a secure way
            audioPlayer = try AVAudioPlayer.init(data: audio)
            audioPlayer.delegate = self
            
            audioPlayer.currentTime = 0
            
            duration.send(audioPlayer.duration)
            
            audioPlayer.play()
            initialiseTimerRunning()
            playStatus = true
        } catch  let error {
            debugLog(error.localizedDescription)
        }
    }
    
    
    func startPlaying () {
        
        audioPlayer.play()
        playStatus = true
    }
    //  pauses the playback
    func stopPlayback() {
        audioPlayer.pause()
        playStatus = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            playStatus = false
            audioPlayerDidFinishPlaying.send(true)
        }
    }
    
    //  not implemented yet, but could be used in a UI implementation where a play or pause button is displayed based on the status of the audiio player
    func isPlaying() -> Bool {
        return playStatus
    }
    
    
    func fastForwardRecord() {
        
        var timeForward = audioPlayer.currentTime
        
        timeForward += 15.0
        if (timeForward > audioPlayer.duration) {
            audioPlayer.currentTime = audioPlayer.duration
        } else {
            audioPlayer.currentTime = timeForward
        }
    }
    
    func rewindBackRecord() {
        var timeBack = audioPlayer.currentTime
        
        timeBack -= 15.0
        if (timeBack > 0) {
            audioPlayer.currentTime = timeBack
        } else {
            audioPlayer.currentTime = 0
        }
    }
    
    func initialiseTimerRunning()  {
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
    }
    
    @objc func timerRunning() {
        currentTime.send(audioPlayer.currentTime)
    }
}
