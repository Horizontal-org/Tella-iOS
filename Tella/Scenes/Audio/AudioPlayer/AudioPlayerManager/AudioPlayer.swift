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
    var audioPlayer: AVAudioPlayer?
    private var timer = Timer()
    var stopTimer: Timer?
    
    var currentTime = CurrentValueSubject<TimeInterval, Never>(0.0)
    var endTime : TimeInterval?
    
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
    
    func startPlaying () {
        audioPlayer?.play(atTime: self.currentTime.value)
        playStatus = true
        
        if let endTime  {
            // Schedule a timer to stop after the specified duration
            stopTimer = Timer.scheduledTimer(withTimeInterval: endTime, repeats: false) { [weak self] _ in
                self?.audioPlayer?.stop()
                self?.audioPlayerDidFinishPlaying.send(true)
            }
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        playStatus = false
        stopTimer?.invalidate()
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        playStatus = false
        stopTimer?.invalidate()
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
    
    func setTime(startTime:TimeInterval, endTime:TimeInterval) {
        // Set start time
        self.currentTime.send(startTime)
        self.endTime = endTime
    }
    
    func initialiseTimerRunning()  {
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
    }
    
    @objc func timerRunning() {
        guard let time = audioPlayer?.currentTime, time != self.currentTime.value else { return }
        currentTime.send(time)
    }
}
