//
//  EditAudioViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Combine
import Foundation
import AVFoundation
import SwiftUI

class EditAudioViewModel: ObservableObject {
    
    @Published var startTime: Double = 0.0
    @Published var endTime: Double = 0.0
    @Published var isPlaying = false
    var cancellable: Set<AnyCancellable> = []
    
    @Published var playingOffset: CGFloat = 0.0
    
    var audioUrl: URL?
    let kNumberOfLabels = 5 // This is for the sub-times labels
    @Published var currentTime : String  = "00:00:00"
    @Published var duration : String  = "00:00:00"
    private var currentData : Data?

    var audioPlayerManager: AudioPlayerManager = AudioPlayerManager()
    
    @ObservedObject private var fileListViewModel: FileListViewModel

    let gapTime = 3.9 // this is the limit time of the audio duration
    var playButtonImageName: String {
        isPlaying ? "mic.pause-audio" : "mic.play"
    }
    @Published var trimState: ViewModelState<Bool> = .loaded(false)
    @Published var timeDuration: Double = 0.0

    private var rootFile: VaultFileDB?
    
    init(fileListViewModel: FileListViewModel) {
        self.fileListViewModel = fileListViewModel
        if let currentFile = fileListViewModel.currentSelectedVaultFile {
            self.currentData = fileListViewModel.appModel.vaultManager.loadFileData(file: currentFile)
        }
        self.rootFile = fileListViewModel.rootFile
        listenToAudioPlayerUpdates()
        loadAudio()
    }
    
    func loadAudio() {
        
        guard let currentData else { return }
        
        DispatchQueue.main.async {
            self.audioPlayerManager.currentAudioData = currentData
            self.audioPlayerManager.initPlayer()
        }
    }

    private func listenToAudioPlayerUpdates() {
        self.audioPlayerManager.audioPlayer.currentTime.sink { value in
            self.currentTime = value.formattedAsHHMMSS()
            self.updateOffset(time: Double(value) )
        }.store(in: &self.cancellable)
        
        self.audioPlayerManager.audioPlayer.duration.sink { value in
            self.duration = value.formattedAsHHMMSS()
            self.timeDuration = value
            self.endTime = value
        }.store(in: &self.cancellable)
        
        self.audioPlayerManager.audioPlayer.audioPlayerDidFinishPlaying.sink { [self] value in
            isPlaying = false
        }.store(in: &self.cancellable)
    }
    
    func onAppear() {
        guard let fileExtension = fileListViewModel.currentSelectedVaultFile?.fileExtension else { return }
        let url = fileListViewModel.appModel.vaultManager.saveDataToTempFile(data: currentData, pathExtension: fileExtension)
        guard let url else { return }
        
        self.audioUrl = url
    }
    
    func onDisappear() {
        self.onPause()
    }
    
    func isDurationHasChanged() -> Bool {
        return self.endTime != self.timeDuration || self.startTime != 0.0
    }
    
    func trimAudio() {
        Task {
            do {
                guard let trimmedAudioUrl = audioUrl?.deletingLastPathComponent().appendingPathComponent("\(newFileName).m4a") else { return }
                try await trimAudio(audioUrl: audioUrl,
                                    trimmedAudioUrl: trimmedAudioUrl,
                                    startTime: startTime,
                                    endTime: endTime)
                self.addEditedFile(urlFile: trimmedAudioUrl)
            } catch {
                self.trimState = .error(error.localizedDescription)
            }
        }
    }
    
    var newFileName: String {
        
        guard let name = fileListViewModel.currentSelectedVaultFile?.name else {
            return ""
        }
        
        var baseName: String
        var copyNumber = 0
        
        // Check if the current name already has the "copy" suffix
        if name.hasSuffix(LocalizableVault.copy.localized) {
            baseName = name
        } else {
            baseName = name + LocalizableVault.copy.localized
        }
        
        // Generate the new filename and check if it exists
        var newFileName = baseName
        while fileListViewModel.appModel.vaultFilesManager?.vaultFileExists(name: newFileName) == true {
            copyNumber += 1
            newFileName = baseName + "-" + "\(copyNumber)"
        }
        
        return newFileName
    }
    
    private func onPlay() {
        audioPlayerManager.playRecord()
    }
    
    private func onPause() {
        audioPlayerManager.pauseRecord()
    }
    
    func handlePlayButton() {
        isPlaying.toggle()
        self.isPlaying ? onPlay() : onPause()
    }
    
    private func addEditedFile(urlFile:URL) {
        let importedFiles = ImportedFile(urlFile: urlFile,
                                         parentId: fileListViewModel.rootFile?.id ,
                                         fileSource: FileSource.files)
        fileListViewModel.appModel.addVaultFile(importedFiles: [importedFiles],
                                                shouldReloadVaultFiles: $fileListViewModel.shouldReloadVaultFiles)
        
        DispatchQueue.main.async {
            self.trimState = .loaded(true)
        }
    }
    
    
    func generateTimeLabels() -> [String] {
        let interval = timeDuration / TimeInterval(kNumberOfLabels - 1)
        var times: [String] = []
        
        for i in 0..<kNumberOfLabels {
            let currentTime = TimeInterval(i) * interval
            times.append(currentTime.formattedAsMMSS())
        }
        return times
    }
    
    private func updateOffset(time: Double) {
        let totalOffsetDistance: CGFloat = 340
        let progress = time / timeDuration
        if !progress.isNaN {
            playingOffset = CGFloat(progress) * totalOffsetDistance
        }
    }
    
    nonisolated func trimAudio(audioUrl:URL?,
                               trimmedAudioUrl:URL?,
                               startTime: Double,
                               endTime :Double ) async throws {
      
        guard let audioUrl else {
            return
        }
        
        let asset = AVAsset(url: audioUrl)
        let startTime = CMTime(seconds: startTime, preferredTimescale: 600)
        let endTime = CMTime(seconds: endTime, preferredTimescale: 600)
        let duration = CMTimeSubtract(endTime, startTime)
        
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
        
        exportSession?.outputURL = trimmedAudioUrl
        exportSession?.outputFileType = .m4a
        exportSession?.timeRange = CMTimeRange(start: startTime, duration: duration)
        
        await exportSession?.export()
        
        if exportSession?.status == .completed {
        } else {
            throw RuntimeError(LocalizableError.commonError.localized)
        }
    }
}
