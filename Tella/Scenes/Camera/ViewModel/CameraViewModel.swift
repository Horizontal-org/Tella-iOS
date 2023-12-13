//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine
import UIKit
import SwiftUI
import AVFoundation
import AVKit
import AssetsLibrary

class CameraViewModel: ObservableObject {
    
    // MARK: - Public properties
    
    var resultFile : Binding<[VaultFileDB]?>?
    
    @Published var lastImageOrVideoVaultFile :  VaultFileDB?
    @Published var isRecording : Bool = false
    @Published var formattedCurrentTime : String = "00:00:00"
    @Published var currentTime : TimeInterval = 0.0
    @Published var progressFile:ProgressFile = ProgressFile()
    var  shouldReloadVaultFiles : Binding<Bool>?
    
    
    var imageData : Data?
    var image : UIImage?
    
    var videoURL : URL?
    var mainAppModel: MainAppModel?
    
    var rootFile: VaultFileDB?
    var sourceView : SourceView
    var shouldShowProgressView : Bool {
        return resultFile != nil
    }
    
    // MARK: - Private properties
    
    private var cancellable: Set<AnyCancellable> = []
    private var timer = Timer()
    
    // MARK: - Public functions
    
    init(mainAppModel: MainAppModel,
         rootFile: VaultFileDB?,
         resultFile : Binding<[VaultFileDB]?>? = nil,
         sourceView : SourceView,
         shouldReloadVaultFiles : Binding<Bool>?) {
        
        self.mainAppModel = mainAppModel
        self.rootFile = rootFile
        
        self.lastImageOrVideoVaultFile = mainAppModel.vaultFilesManager?.getVaultFiles(parentId: nil, filter: FilterType.photoVideo, sort: FileSortOptions.newestToOldest).first
        
        self.resultFile = resultFile
        
        self.sourceView = sourceView
        
        self.shouldReloadVaultFiles = shouldReloadVaultFiles
    }
    
    func saveImage() {
        
        guard let imageData = image?.fixedOrientation()?.pngData() else { return  }
        guard let url = mainAppModel?.vaultManager.saveDataToTempFile(data: imageData, pathExtension: "png") else { return  }
        
        saveFile(urlFile: url)
    }
    
    func saveVideo() {
        guard let videoURL = videoURL else { return  }
        saveFile(urlFile: videoURL)
    }
    
    private func saveFile(urlFile:URL) {
        
        if shouldShowProgressView {
            addVaultFileWithProgressView(urlFile: urlFile)
        } else {
            addVaultFileInBackground(urlFile: urlFile)
        }
    }
    
    private func addVaultFileWithProgressView(urlFile:URL) {
        self.mainAppModel?.vaultFilesManager?.addVaultFile(filePaths: [urlFile], parentId: self.rootFile?.id)
            .sink { importVaultFileResult in
                
                switch importVaultFileResult {
                    
                case .fileAdded(let vaultFiles):
                    self.handleSuccessAddingFiles(vaultFiles: vaultFiles)
                case .importProgress(let importProgress):
                    self.updateProgress(importProgress:importProgress)
                }
                
            }.store(in: &cancellable)
    }
    
    private func addVaultFileInBackground(urlFile:URL) {
        self.mainAppModel?.addVaultFile(filePaths: [urlFile], parentId: self.rootFile?.id, shouldReloadVaultFiles : self.shouldReloadVaultFiles)
    }
    
    private func handleSuccessAddingFiles(vaultFiles:[VaultFileDB]) {
        self.updateResultFile(vaultFiles:vaultFiles)
        self.sendAutoReport(vaultFiles: vaultFiles)
    }
    
    private func updateProgress(importProgress:ImportProgress) {
        DispatchQueue.main.async {
            self.progressFile.progress = importProgress.progress.value
            self.progressFile.progressFile = importProgress.progressFile.value
            self.progressFile.isFinishing = importProgress.isFinishing.value
        }
    }
    
    private func sendAutoReport(vaultFiles:[VaultFileDB])  {
        if self.sourceView != .addReportFile {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if let file = vaultFiles.first {
                    self.mainAppModel?.sendAutoReportFile(file: file)
                }
            }
        }
    }
    
    private func updateResultFile(vaultFiles:[VaultFileDB])  {
        DispatchQueue.main.async {
            self.resultFile?.wrappedValue = vaultFiles
            self.shouldReloadVaultFiles?.wrappedValue = true
            self.lastImageOrVideoVaultFile = vaultFiles.first
        }
    }
    
    
    func initialiseTimerRunning() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
    }
    
    func invalidateTimerRunning() {
        self.timer.invalidate()
        currentTime = 0.0
        self.formattedCurrentTime = currentTime.stringFromTimeInterval()
    }
    
    // MARK: - Private functions
    @objc private func timerRunning() {
        currentTime = currentTime + 1
        self.formattedCurrentTime = currentTime.stringFromTimeInterval()
    }
}
