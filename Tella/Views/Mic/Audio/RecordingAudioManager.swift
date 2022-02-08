//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import AVFoundation
import UIKit
import Combine

class RecordingAudioManager: AudioRecorderManager, ObservableObject {

    private var audioPlayer = AudioPlayer()
    private var recorder: AVAudioRecorder!
    var currentFileName: URL?
    var audioFileURL = PassthroughSubject<URL?, Never>()
   
    var currentTime = CurrentValueSubject<TimeInterval, Never>(0.0)
    
    private var previousTime : TimeInterval = 0
    private var timer = Timer()

    var queuePlayer: AVQueuePlayer?
    var articleChunks = [AVURLAsset]()

    var mainAppModel: MainAppModel?

    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    func startRecording() {

        self.queuePlayer?.pause()

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
            initialiseTimerRunning()
        } catch let error {
            // @TODO Delegate this to the ViewModel
            print("Error is", error)
            return
        }
    }
    
    
 
    

    func stopRecording(fileName:String) {
        pauseRecording()
        concatChunks(fileName: fileName)
    }
    
    func pauseRecording() {
        self.timer.invalidate()

        self.recorder.stop()

        let assetURL = self.recorder!.url
        let assetOpts = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        let asset     = AVURLAsset(url: assetURL, options: assetOpts)
        self.articleChunks.append(asset)

    }

    func resetRecorder() {
        self.discardRecord()
        
      
    }
    
    internal func discardRecord() {
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

    func playRecord() {

        let assetKeys = ["playable"]
        let playerItems = self.articleChunks.map {
            AVPlayerItem(asset: $0, automaticallyLoadedAssetKeys: assetKeys)
        }

        self.queuePlayer = AVQueuePlayer(items: playerItems)
        self.queuePlayer?.actionAtItemEnd = .advance

        self.queuePlayer?.play()

        
        
        
        
//        self.audioPlayer.startPlayback(audio: audioData)
        
    }
    
    
    func pauseRecord() {
        self.queuePlayer?.pause()
        self.queuePlayer = nil
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
    
    
    
    private func concatChunks(fileName:String) {
        let composition = AVMutableComposition()

        var insertAt = CMTimeRange(start: CMTime.zero, end: CMTime.zero)

        for asset in self.articleChunks {
            let assetTimeRange = CMTimeRange(
                start: CMTime.zero,
                end:   asset.duration)

            do {
                try composition.insertTimeRange(assetTimeRange,
                                                of: asset,
                                                at: insertAt.end)
            } catch {
                NSLog("Unable to compose asset track.")
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
        exportSession?.outputURL = self.getFileName()


        exportSession?.canPerformMultiplePassesOverSourceMediaData = true

        exportSession?.exportAsynchronously {

            switch exportSession?.status {
            case .unknown?: break
            case .waiting?: break
            case .exporting?: break
            case .completed?:
              
              self.currentFileName = exportSession?.outputURL
              
//                self.audioFileURL.send(exportSession?.outputURL)
                if let url = exportSession?.outputURL {
                    self.mainAppModel?.add(audioFilePath: url, to: self.mainAppModel?.vaultManager.root, type: .audio, fileName: fileName)
                }
                
                self.resetRecorder()

                
                
                for asset in self.articleChunks {
                    try! FileManager.default.removeItem(at: asset.url)
                }

                self.articleChunks = [AVURLAsset]()
                exportSession?.cancelExport()

                
            case .failed?: break
            case .cancelled?: break
            case .none: break
            }
        }
    }

    func initialiseTimerRunning()  {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
    }
    
    @objc func timerRunning() {
        
        previousTime = previousTime + 1

        currentTime.send(previousTime)
    }

    
}
