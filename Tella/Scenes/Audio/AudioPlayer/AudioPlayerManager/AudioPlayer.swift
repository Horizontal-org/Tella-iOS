//
//  AudioPlayer.swift
//  Tella
//
//  Created by Erin Simshauser on 5/8/20.
//  Copyright © 2020 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
    var audioPlayer: AVAudioPlayer?
    private var timer = Timer()
    
    var currentTime = CurrentValueSubject<TimeInterval, Never>(0.0)
    var duration = 0.0
    var audioPlayerDidFinishPlaying = CurrentValueSubject<Bool, Never>(false)
    
    
    
    func initPlayer(audio: Data) {
        
        do {
            audioPlayer = try AVAudioPlayer.init(data: audio)
            audioPlayer?.delegate = self
            audioPlayer?.currentTime = 0
            duration = audioPlayer?.duration ?? 0
            initialiseTimerRunning()
        } catch  let error {
            debugLog(error.localizedDescription)
        }
    }
    func seekAudio(to position: TimeInterval ) {
        audioPlayer?.currentTime = position
    }
    
    func startPlaying () {
        
        audioPlayer?.play()
        playStatus = true
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        playStatus = false
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        playStatus = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            playStatus = false
            audioPlayerDidFinishPlaying.send(true)
        }
    }
    
    func isPlaying() -> Bool {
        return playStatus
    }
    
    func fastForwardRecord() {
        
        guard var timeForward = audioPlayer?.currentTime, let duration = audioPlayer?.duration else { return }
        
        timeForward += 15.0
        if (timeForward > duration) {
            audioPlayer?.currentTime = duration
        } else {
            audioPlayer?.currentTime = timeForward
        }
    }
    
    func rewindBackRecord() {
        guard var timeBack = audioPlayer?.currentTime else { return }
        
        timeBack -= 15.0
        if (timeBack > 0) {
            audioPlayer?.currentTime = timeBack
        } else {
            audioPlayer?.currentTime = 0
        }
    }
    
    func initialiseTimerRunning()  {
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
    }
    
    @objc func timerRunning() {
        guard let time = audioPlayer?.currentTime, time != self.currentTime.value else { return }
        currentTime.send(time)
    }
}
