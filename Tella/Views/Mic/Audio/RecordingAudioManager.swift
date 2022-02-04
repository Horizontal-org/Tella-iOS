//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import AVFoundation

class RecordingAudioManager: AudioRecorderManager {
    
    private var audioPlayer = AudioPlayer()
    private var recorder: AVAudioRecorder!
     var currentFileName: URL?
    
    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    func startRecording() {
        guard
            self.configureSession(),
            let fileName = self.getFileName()
        else {
            // @TODO Delegate this to the viewModel
            return
        }
        
        do {
            self.recorder = try AVAudioRecorder(url: fileName, settings: settings)
            self.currentFileName = fileName
            self.recorder.record()
        } catch let error {
            // @TODO Delegate this to the ViewModel
            print("Error is", error)
            return
        }
    }
    
    func stopRecording() {
        self.recorder.stop()
    }
    
    func pauseRecording() {
        self.recorder.pause()
    }

    func saveRecord() {
        guard
            let audioData = self.getCurrentAudio()
        else { return }
        
        //TODO: fix
//        TellaFileManager.saveAudio(audioData)
        
        self.discardRecord()
    }
    
    func discardRecord() {
        guard
            let fileName = self.currentFileName
        else { return }
        
        do {
            try FileManager.default.removeItem(at: fileName)
        } catch let error {
            // @TODO Delegate this error
            print("Failed to remove file!", error)
        }
    }
    
    func resetRecorder() {
        
    }
    
    func playRecord() {
        guard
            let audioData = self.getCurrentAudio()
        else { return }
        
        self.audioPlayer.startPlayback(audio: audioData)
        
    }
    
    func stopRecord() {
        self.audioPlayer.stopPlayback()
    }
    
    func getCurrentAudio() -> Data? {
        guard
            let url = self.currentFileName
        else { return nil }
        
        return try? Data(contentsOf: url)
    }
    
    fileprivate func getFileName() -> URL? {
        
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(Int(Date().timeIntervalSince1970)).m4a")
    }
    
    fileprivate func configureSession() -> Bool {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch let error {
            // @TODO Delegate this to the ViewModel
            print("Error is", error)
            return false
        }
        
        return true
        
    }
    
}
