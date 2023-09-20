//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import AVFoundation
import UIKit
import Combine

class RecordingAudioManager: AudioRecorderManager, ObservableObject {
    
    private var recorder: AVAudioRecorder!
    private var queuePlayer = QueuePlayer()
    private var audioChunks = [AVURLAsset]()
    private var currentFileURL: URL?
    private var timer = Timer()
    
    var currentTime = CurrentValueSubject<TimeInterval, Never>(0.0)
    @Published var audioPermission : AudioAuthorizationStatus = .notDetermined
    var fileURL = CurrentValueSubject<URL?, Never>(nil)

//    var mainAppModel: MainAppModel
//    var rootFile: VaultFile

    private let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    init() {

        guard
            self.configureSession()
        else {
            return
        }
        
    }
    
    func startRecording() {
        
        self.queuePlayer.pauseAudio()
        
        guard let fileURL = self.getFileURL()
        else { return }
        
        self.currentFileURL = fileURL

        do {
            self.recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            self.recorder.record()
            
            initialiseTimerRunning()
        } catch let error {
            debugLog(error)
            return
        }
    }
    
    func stopRecording(fileName:String) {
        concatChunks(fileName: fileName)
        currentTime.send(0)
    }
    
    func pauseRecording() {
        
        self.timer.invalidate()
        
        self.recorder.stop()
        
        let assetURL = self.recorder!.url
        let assetOpts = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        let asset     = AVURLAsset(url: assetURL, options: assetOpts)
        self.audioChunks.append(asset)
    }

    func discardRecord() {
        for asset in self.audioChunks {
            do {
                try FileManager.default.removeItem(at: asset.url)
            } catch {
                
            }
        }
        guard let currentFileURL else { return  }
        
        do {
            try FileManager.default.removeItem(at: currentFileURL)
        } catch {
            
        }
    }
    
    func playRecord() {
        
        let assetKeys = ["playable"]
        let playerItems = self.audioChunks.map {
            AVPlayerItem(asset: $0, automaticallyLoadedAssetKeys: assetKeys)
        }
        
        queuePlayer.playAudio(playerItems: playerItems)
    }
    
    
    func pauseRecord() {
        queuePlayer.pauseAudio()
    }
    
    fileprivate func getFileURL(fileName:String? = nil) -> URL? {
        let pathURL = URL(fileURLWithPath:NSTemporaryDirectory())
        let fileName = fileName ?? "\(Int(Date().timeIntervalSince1970))"
        return pathURL.appendingPathComponent("\(fileName).m4a")
    }
    
    fileprivate func configureSession() -> Bool {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: [.defaultToSpeaker])

            try session.setActive(true)
        } catch let error {
            debugLog(error)
            return false
        }
        return true
    }
    
    private func concatChunks(fileName:String) {
        let composition = AVMutableComposition()
        
        var insertAt = CMTimeRange(start: CMTime.zero, end: CMTime.zero)
        
        for asset in self.audioChunks {
            let assetTimeRange = CMTimeRange(
                start: CMTime.zero,
                end:   asset.duration)
            
            do {
                try composition.insertTimeRange(assetTimeRange,
                                                of: asset,
                                                at: insertAt.end)
            } catch {
            }
            
            let nextDuration = insertAt.duration + assetTimeRange.duration
            insertAt = CMTimeRange(
                start:    CMTime.zero,
                duration: nextDuration)
        }
        
        let exportSession =
        AVAssetExportSession(
            asset:      composition,
            presetName: AVAssetExportPresetAppleM4A)
        
        
        exportSession?.outputFileType = AVFileType.m4a
        exportSession?.outputURL = self.getFileURL(fileName: fileName) // fileName true
        
        
        exportSession?.canPerformMultiplePassesOverSourceMediaData = true
        
        exportSession?.exportAsynchronously {
            
            switch exportSession?.status {
            case .unknown?: break
            case .waiting?: break
            case .exporting?: break
            case .completed?:
                
                self.currentFileURL = exportSession?.outputURL
                
                if let url = exportSession?.outputURL {
//                    self.mainAppModel.add(audioFilePath: url, to: self.rootFile, type: .audio, fileName: fileName)
                    self.fileURL.send(url)

                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.discardRecord()
                })
                
                self.audioChunks = [AVURLAsset]()
                exportSession?.cancelExport()
                
                
            case .failed?: break
            case .cancelled?: break
            case .none: break
            case .some(_): break
            }
        }
    }
    
    private func initialiseTimerRunning()  {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
    }
    
    @objc private func timerRunning() {
        currentTime.send(currentTime.value + 1)
    }
    
    func checkMicrophonePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .denied:
            audioPermission = .denied
        case .restricted:
            audioPermission = .restricted
            
        case .authorized:
            audioPermission = .authorized
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { success in
                if success {
                    self.audioPermission = .authorized
                }
            }
        @unknown default:
            break
        }
    }
}
