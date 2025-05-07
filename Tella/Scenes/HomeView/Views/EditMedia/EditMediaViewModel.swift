//
//  EditMediaViewModel.swift
//  Tella
//
//  Created by RIMA on 14.11.24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine
import SwiftUI
import AVFoundation

class EditMediaViewModel: ObservableObject {
    //MARK: - Published
    @Published var startTime: Double = 0.0
    @Published var endTime: Double = 0.0
    @Published var timeDuration: Double = 0.0
    @Published var currentTime : String  = "00:00:00"
    @Published var isPlaying = false
    @Published var trimState: ViewModelState<Bool> = .loaded(false)
    @Published var headerTitle = ""
    
    @Published var trailingGestureValue: Double = 0.0
    @Published var leadingGestureValue: Double = 0.0
    @Published var shouldStopLeftScroll = false
    @Published var shouldStopRightScroll = false
    @Published var currentPosition: CGFloat = .zero

    @Published var isDraggingLeft = false
    @Published var isDraggingRight = false

    //MARK: - View attributes
    let minimumAudioDuration = 3.0 // this is the limit time of the audio duration
    let kTrimViewWidth = UIScreen.screenWidth - 32 - 18
    var timeSlots: [String] = []
    var playButtonImageName: String {
        isPlaying ? "mic.pause-audio" : "mic.play"
    }
    var fileURL: URL?
    
    
    //MARK: - cancellable
    var cancellables: Set<AnyCancellable> = []
    
    //MARK: - Init attributes
    var file: VaultFileDB?
    var rootFile: VaultFileDB?
    var appModel: MainAppModel
    var editMedia : EditMediaProtocol
    
    init(file: VaultFileDB?, rootFile: VaultFileDB?, appModel: MainAppModel, editMedia:EditMediaProtocol) {
        self.file = file
        self.rootFile = rootFile
        self.appModel  = appModel
        self.editMedia  = editMedia
    }
    
    func onAppear() {
        guard let file, let fileURL = self.appModel.vaultManager.loadVaultFileToURL(file: file)  else {return}
        self.fileURL = fileURL
        self.timeDuration = file.duration ?? 0.0
        self.endTime = self.timeDuration
    }
    
    func onDisappear() {
        self.onPause()
    }
    
    func isDurationHasChanged() -> Bool {
        return self.endTime != self.timeDuration || self.startTime != 0.0
    }
    
    func isVideoRotated() -> Bool {
        return true
    }

    func onPlay() {}
    
    func onPause() {}
    
    func trim() {
        Task { @MainActor in
            do {
                self.trimState = .loading
                let copyName = file?.getCopyName(from: appModel.vaultFilesManager) ?? ""
                guard let trimmedVideoUrl = try await fileURL?.trimMedia(newName: copyName, startTime: startTime, endTime: endTime) else { return }
                self.addEditedFile(urlFile: trimmedVideoUrl)
                self.trimState = .loaded(true)
             } catch {
                self.trimState = .error(error.localizedDescription)
            }
        }
    }
    
    func didReachSliderLimit() {
    }
    
    func handlePlayButton() {
        isPlaying.toggle()
        isPlaying ? onPlay() : onPause()
    }
    
    func addEditedFile(urlFile:URL) {
        let importedFiles = ImportedFile(urlFile: urlFile,
                                         parentId: rootFile?.id ,
                                         fileSource: FileSource.files)
        appModel.addVaultFile(importedFiles: [importedFiles])
    }
    
    func undo() {
       startTime = 0.0
       endTime = timeDuration
       leadingGestureValue = 0.0
       trailingGestureValue = kTrimViewWidth
   }
}



protocol EditMediaProtocol {
    var leadingImageName: String { get }
    var trailingImageName: String { get }
    var playImageName: String { get }
    var leadingPadding: CGFloat { get }
    var trailingPadding: CGFloat { get }
}

struct EditVideoParameters : EditMediaProtocol {
    var leadingImageName: String = "edit.video.left.icon"
    var trailingImageName: String = "edit.video.right.icon"
    var playImageName: String = "edit.video.play.line"
    var leadingPadding: CGFloat = 0.0
    var trailingPadding: CGFloat = UIScreen.screenWidth - 32 - 18
}

struct EditAudioParameters : EditMediaProtocol {
    var leadingImageName: String = "edit.audio.trim.line"
    var trailingImageName: String = "edit.audio.trim.line"
    var playImageName: String =  "edit.audio.play.line"
    var leadingPadding: CGFloat = 0.0
    var trailingPadding: CGFloat = UIScreen.screenWidth - 32 - 18
}
