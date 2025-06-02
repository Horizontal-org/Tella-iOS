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
    @Published var currentPosition: CGFloat = .zero
    
    @Published var isDraggingLeft = false
    @Published var isDraggingRight = false
    
    //MARK: - View attributes
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
    
    init(file: VaultFileDB?, fileURL: URL?, rootFile: VaultFileDB?, appModel: MainAppModel, editMedia:EditMediaProtocol) {
        self.file = file
        self.fileURL = fileURL
        self.rootFile = rootFile
        self.appModel  = appModel
        self.editMedia  = editMedia
    }
    
    func onAppear() {
        self.timeDuration = file?.duration ?? 0.0
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
    
    func resetSliderToStart() {
        currentPosition = startTime
        updateCurrentPosition()
    }
    
    func updateCurrentPosition()  {
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
        trailingGestureValue = editMedia.trailingPadding
    }
}
