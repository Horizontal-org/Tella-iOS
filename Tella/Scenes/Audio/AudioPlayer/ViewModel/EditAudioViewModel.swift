//
//  EditAudioViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Combine
import Foundation
import AVFoundation

class EditAudioViewModel: ObservableObject {
    
    @Published var startTime: Double = 0.0
    @Published var endTime: Double = 0.0
    
    @Published var isPlaying = false
    var cancellable: Set<AnyCancellable> = []

    @Published var offset: CGFloat = 0.0

    var audioUrl: URL?
    let kNumberOfLabels = 5 // This is for the sub-times labels
    
    @Published var currentTime : String  = "00:00:00"
    @Published private var currenTimeValue: Double = 0.0
    @Published var audioPlayerViewModel: AudioPlayerViewModel
    var playButtonImageName: String {
        isPlaying ? "mic.pause-audio" : "mic.play" 
    }
    
    var timeDuration: Double {
        return Double(audioPlayerViewModel.timeDuration ?? 0)
    }
    
    var duration: String {
        return audioPlayerViewModel.duration
    }

    init(audioPlayerViewModel : AudioPlayerViewModel) {
        self.audioPlayerViewModel = audioPlayerViewModel
        
        self.audioPlayerViewModel.audioPlayerManager.audioPlayer.currentTime.sink { value in
            self.currentTime = value.toHHMMSSString()
            self.currenTimeValue = Double(value)
            self.updateOffset()
        }.store(in: &self.cancellable)

    }
    
    func onAppear() {
        guard let fileExtension = audioPlayerViewModel.currentFile?.fileExtension else { return }
        let url = audioPlayerViewModel.mainAppModel.vaultManager.saveDataToTempFile(data: audioPlayerViewModel.currentData,
                                                                                                       pathExtension: fileExtension)
        guard let url else { return }
        
        self.audioUrl = url
        self.endTime = Double(audioPlayerViewModel.timeDuration ?? 0)
    }
    
    func trimAudio() {
        guard let audioUrl = audioUrl else { return }
        
        let asset = AVAsset(url: audioUrl)
        let startTime = CMTime(seconds: startTime, preferredTimescale: 600)
        let endTime = CMTime(seconds: endTime, preferredTimescale: 600)
        let duration = CMTimeSubtract(endTime, startTime)
        
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
        let trimmedAudioUrl = audioUrl.deletingLastPathComponent().appendingPathComponent("trimmedAudio1.m4a")
        
        exportSession?.outputURL = trimmedAudioUrl
        exportSession?.outputFileType = .m4a
        exportSession?.timeRange = CMTimeRange(start: startTime, duration: duration)
        
        exportSession?.exportAsynchronously {
            switch exportSession?.status {
            case .completed:
                print("Audio trimmed successfully to: \(trimmedAudioUrl)")
                self.addSynchronousVaultFile(urlFile: trimmedAudioUrl)
            case .failed:
                if let error = exportSession?.error {
                }
            default:
                break
            }
        }
    }
    
    private func onPlay() {
        audioPlayerViewModel.audioPlayerManager.playRecord()
    }
    
    private func onPause() {
        audioPlayerViewModel.audioPlayerManager.pauseRecord()
    }
    
    func handlePlayButton() {
        isPlaying.toggle()
        self.isPlaying ? onPlay() : onPause()
    }
    
    private func addSynchronousVaultFile(urlFile:URL) {
        
        let importedFiles = ImportedFile(urlFile: urlFile,
                                         parentId: audioPlayerViewModel.currentFile?.id ,
                                         fileSource: FileSource.files)
        
        audioPlayerViewModel.mainAppModel.vaultFilesManager?.addVaultFile(importedFiles : [importedFiles])
            .sink { importVaultFileResult in
                
                switch importVaultFileResult {
                    
                case .fileAdded(let vaultFiles):
                    guard let vaultFile = vaultFiles.first else { return  }
                    //                    self.handleSuccessAddingFiles(vaultFile: vaultFile)
                    print("file added succesfully")
                case .importProgress:
                    break
                }
                
            }.store(in: &audioPlayerViewModel.cancellable)
    }
    
    
    func generateTimeLabels() -> [String] {
        guard let timeDuration = audioPlayerViewModel.timeDuration else { return []}
        let interval = timeDuration / TimeInterval(kNumberOfLabels - 1)
        var times: [String] = []
        
        for i in 0..<kNumberOfLabels {
            let currentTime = TimeInterval(i) * interval
            times.append(currentTime.toHHMMString())
        }
        return times
    }

    func undo() {
        self.startTime = 0.0
        self.endTime = Double(audioPlayerViewModel.timeDuration ?? 0)
    }
    
    
    
    
    private func updateOffset() {
//        guard let player = audioPlayer else { return }
//
//        let duration = player.duration
//        let currentTime = player.currentTime

        // Assuming 300 points is the total offset distance for the view
        let totalOffsetDistance: CGFloat = 340
        let progress = currenTimeValue / timeDuration

        // Update the offset based on audio progress
        offset = CGFloat(progress) * totalOffsetDistance
    }

}




