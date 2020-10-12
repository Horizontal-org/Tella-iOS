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
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch let error {
            // @TODO Delegate this to the ViewModel
            print("Error is", error)
            return
        }
        
        guard
            let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            // @TODO Delegate this to the ViewModel
            return
        }
        
        let fileName = docPath.appendingPathComponent("\(Int(Date().timeIntervalSince1970)).m4a")
        
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
    
    
}
