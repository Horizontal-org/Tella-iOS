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
    var shouldReloadVaultFiles : Binding<Bool>?
    
    @Published var isPlaying = false
    var cancellable: Set<AnyCancellable> = []
    
    @Published var playingOffset: CGFloat = 0.0
    
    var audioUrl: URL?
    let kNumberOfLabels = 5 // This is for the sub-times labels
    @Published var currentTime : String  = "00:00:00"
    @ObservedObject var audioPlayerViewModel: AudioPlayerViewModel
    
    let gapTime = 3.9 // this is the limit time of the audio duration
    var playButtonImageName: String {
        isPlaying ? "mic.pause-audio" : "mic.play"
    }
    @Published var trimState: ViewModelState<Bool> = .loaded(false)
    
    @Published var timeDuration: Double = 0.0
    
    var duration: String {
        return audioPlayerViewModel.duration
    }
    private var rootFile: VaultFileDB?
    
    init(audioPlayerViewModel: AudioPlayerViewModel, shouldReloadVaultFiles : Binding<Bool>?, rootFile: VaultFileDB?) {
        self.audioPlayerViewModel = audioPlayerViewModel
        self.shouldReloadVaultFiles = shouldReloadVaultFiles
        self.rootFile = rootFile
        listenToAudioPlayerUpdates()
    }
    
    private func listenToAudioPlayerUpdates() {
        self.audioPlayerViewModel.audioPlayerManager.audioPlayer.currentTime.sink { value in
            self.currentTime = value.formattedAsHHMMSS()
            self.updateOffset(time: Double(value) )
        }.store(in: &self.cancellable)
        self.audioPlayerViewModel.audioPlayerManager.audioPlayer.duration.sink { value in
            self.timeDuration = value
            self.endTime = value
        }.store(in: &self.cancellable)
    }
    
    
    func onAppear() {
        guard let fileExtension = audioPlayerViewModel.currentFile?.fileExtension else { return }
        let url = audioPlayerViewModel.mainAppModel.vaultManager.saveDataToTempFile(data: audioPlayerViewModel.currentData,
                                                                                    pathExtension: fileExtension)
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
        
        guard let name = audioPlayerViewModel.currentFile?.name else {
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
        while audioPlayerViewModel.mainAppModel.vaultFilesManager?.vaultFileExists(name: newFileName) == true {
            copyNumber += 1
            newFileName = baseName + "-" + "\(copyNumber)"
        }
        
        return newFileName
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
    
    private func addEditedFile(urlFile:URL) {
        let importedFiles = ImportedFile(urlFile: urlFile,
                                         parentId: rootFile?.id ,
                                         fileSource: FileSource.files)
        self.audioPlayerViewModel.mainAppModel.addVaultFile(importedFiles: [importedFiles],
                                                            shouldReloadVaultFiles: shouldReloadVaultFiles)
        
        DispatchQueue.main.async {
            self.shouldReloadVaultFiles?.wrappedValue = true
            self.trimState = .loaded(true)
        }
    }
    
    
    func generateTimeLabels() -> [String] {
        guard let timeDuration = audioPlayerViewModel.timeDuration else { return []}
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
      
        guard let audioUrl = await audioUrl else {
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
