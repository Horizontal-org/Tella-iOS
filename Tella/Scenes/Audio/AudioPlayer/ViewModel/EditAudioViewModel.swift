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
    
    //MARK: - FileListViewModel
    @ObservedObject private var fileListViewModel: FileListViewModel

    //MARK: - Published
    @Published var startTime: Double = 0.0
    @Published var endTime: Double = 0.0
    @Published var timeDuration: Double = 0.0
    @Published var currentTime : String  = "00:00:00"
    @Published var playingOffset: CGFloat = 0.0
    @Published var isPlaying = false
    @Published var trimState: ViewModelState<Bool> = .loaded(false)
        
    //MARK: - AudioPlayerManager
    private var audioPlayerManager: AudioPlayerManager = AudioPlayerManager()
    
    //MARK: - Private attributes
    private var audioUrl: URL?
    private var currentData : Data?

    //MARK: - View attributes
    let gapTime = 3.9 // this is the limit time of the audio duration
    var timeSlots: [String] = []
    var playButtonImageName: String {
        isPlaying ? "mic.pause-audio" : "mic.play"
    }
    //MARK: - cancellable
    var cancellable: Set<AnyCancellable> = []

    init(fileListViewModel: FileListViewModel) {
        self.fileListViewModel = fileListViewModel
        if let currentFile = fileListViewModel.currentSelectedVaultFile {
            self.currentData = fileListViewModel.appModel.vaultManager.loadFileData(file: currentFile)
        }
        loadAudio()
        listenToAudioPlayerUpdates()
    }
    
    func loadAudio() {
        guard let currentData else { return }
        DispatchQueue.main.async {
            self.audioPlayerManager.initPlayer(data: currentData)
        }
    }

    private func listenToAudioPlayerUpdates() {
        self.audioPlayerManager.audioPlayer.currentTime.sink { value in
            self.currentTime = value.formattedAsHHMMSS()
            self.updateOffset(time: Double(value) )
        }.store(in: &self.cancellable)

        self.audioPlayerManager.audioPlayer.duration.sink { value in
            self.timeDuration = value
            self.generateTimeLabels()
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
                guard let trimmedAudioUrl = try await audioUrl?.trimAudio(newName: "\(newFileName).m4a", startTime: startTime, endTime: endTime) else { return }
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
    
    private func generateTimeLabels() {
        if timeDuration != 0.0 {
            let kNumberOfLabels = 5 // This is for the sub-times labels
            let interval = timeDuration / TimeInterval(kNumberOfLabels - 1)
            var times: [String] = []
            for i in 0..<kNumberOfLabels {
                let currentTime = TimeInterval(i) * interval
                times.append(currentTime.formattedAsMMSS())
            }
            timeSlots = times
        }
    }
    
    private func updateOffset(time: Double) {
        let totalOffsetDistance: CGFloat = 340
        let progress = time / timeDuration
        if !progress.isNaN {
            playingOffset = CGFloat(progress) * totalOffsetDistance
        }
    }
}
