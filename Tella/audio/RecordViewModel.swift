//
//  RecordViewModel.swift
//  Tella
//
//  Created by Bruno Pastre on 12/10/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import Foundation

enum RecordState {
    case ready
    case recording
    case paused
    case done
}

enum RecordEvent {
    case save
    case discard
    case start
    case cancel
    case pause
    case resume
    case complete
    
}

protocol AudioBackend {
    func startRecording()
    func stopRecording()
    func saveRecord()
    func discardRecord()
    func resetRecorder()
}

class MockedAudioBackend: AudioBackend {
    func startRecording() {
        
    }
    
    func stopRecording() {
        
    }
    
    func saveRecord() {
        
    }
    
    func discardRecord() {
        
    }
    
    func resetRecorder() {
        
    }
    
    
}

class RecordViewModel: ObservableObject {
    
    @Published var state: RecordState = .ready
    @Published var centerButtonText: String = "Record"
    
    private var audioBackend: AudioBackend = MockedAudioBackend()
    
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
    
    fileprivate func resetRecording() {
        self.state = .ready
        
        self.audioBackend.resetRecorder()
        
        self.updateView()
    }
    
    
    fileprivate func updateView() {
        self.objectWillChange.send()
    }
}
