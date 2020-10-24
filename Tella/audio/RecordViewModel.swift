//
//  RecordViewModel.swift
//  Tella
//
//  Created by Bruno Pastre on 12/10/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import Foundation


class RecordViewModel: ObservableObject {
    
    @Published var state: RecordState = .ready
    
    private var audioBackend: AudioManager = RecordingAudioManager()
    
    func onStartRecording() {
        self.state = .recording
        
        self.audioBackend.startRecording()
        
        self.updateView()
    }
    
    func onStopRecording() {
        self.state = .done
        
        self.audioBackend.stopRecording()
        
        self.updateView()
    }
    
    func onSaveRecording() {
        self.audioBackend.saveRecord()
        self.resetRecording()
    }
    
    func onDiscardRecord() {
        self.audioBackend.discardRecord()
        self.resetRecording()
    }
    
    func onPlayRecord() {
        self.audioBackend.playRecord()
    }
    
    func onPauseRecord() {
        self.audioBackend.stopRecord()
    }
    
    fileprivate func resetRecording() {
        self.state = .ready
        
        self.audioBackend.resetRecorder()
        
        self.updateView()
    }
    
    fileprivate func updateView() {
        self.objectWillChange.send()
    }
}
