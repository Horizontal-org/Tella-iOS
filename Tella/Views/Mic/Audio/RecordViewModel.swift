//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation


class RecordViewModel: ObservableObject {
    
    @Published var state: RecordState = .ready
    
    private var audioBackend: RecordingAudioManager = RecordingAudioManager()
//
    var url : URL? {
        return audioBackend.currentFileName
    }
    
    
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
//        self.audioBackend.pauseRecording()
        self.audioBackend.stopRecording()

        
        self.state = .paused
        self.updateView()

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
