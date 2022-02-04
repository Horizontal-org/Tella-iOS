//
//  AudioViewModel.swift
//  Tella
//
//  Created by Amine Info on 4/2/2022.
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
   
    init() {
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

        
    }
    
    func onStartPlaying() {
        
        self.state = .playing
        
        self.audioPlayerManager.playRecord()
        
        shouldDisableFastForwardButton = false
        shouldDisableRewindBackButton = false

        self.updateView()
    }
    
    func onStopPlaying() {
        self.state = .ready
        
        self.audioPlayerManager.stopRecord()
        
        shouldDisableFastForwardButton = true
        shouldDisableRewindBackButton = true


        self.updateView()
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
