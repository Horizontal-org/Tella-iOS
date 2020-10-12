//
//  RecordingAudioManager.swift
//  Tella
//
//  Created by Bruno Pastre on 12/10/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import AVFoundation

class RecordingAudioManager: AudioManager {
    
    private var recorder: AVAudioRecorder!
    
    func startRecording() {
        guard
            self.configureSession(),
            let fileName = self.getFileName()
        else {
            // @TODO Delegate this to the viewModel
            return
        }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            self.recorder = try AVAudioRecorder(url: fileName, settings: settings)
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
    
    func saveRecord() {
        // TODO
    }
    
    func discardRecord() {
        // TODO
    }
    
    func resetRecorder() {
        
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
