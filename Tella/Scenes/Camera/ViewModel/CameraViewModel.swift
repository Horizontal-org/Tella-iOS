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
import CoreLocation

class CameraViewModel: ObservableObject {
    
    // MARK: - Public properties
    
    var resultFile : Binding<[VaultFileDB]?>?
    
    @Published var lastImageOrVideoVaultFile :  VaultFileDB?
    @Published var isRecording : Bool = false
    @Published var formattedCurrentTime : String = "00:00:00"
    @Published var currentTime : TimeInterval = 0.0
    @Published var progressFile:ProgressFile = ProgressFile()
    @Published var shouldReloadVaultFiles : Binding<Bool>?
    @Published var shouldShowToast : Bool = false

    var imageData : Data?
    var currentLocation:CLLocation?
    
    var videoURL : URL?
    var mainAppModel: MainAppModel?
    
    var rootFile: VaultFileDB?
    var sourceView : SourceView
    var shouldShowProgressView : Bool {
        return resultFile != nil
    }
    
    var autoUpload: Bool {
        self.sourceView != .addReportFile
    }
    
    var errorMessage : String = ""

    
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

        self.resultFile = resultFile
        
        self.sourceView = sourceView
        
        self.shouldReloadVaultFiles = shouldReloadVaultFiles
       
        self.updateLastItem()
        
        self.listenToshouldReloadFiles()
        
    }
    
    private func updateLastItem() {
        DispatchQueue.main.async {
            self.lastImageOrVideoVaultFile = self.mainAppModel?.vaultFilesManager?.getVaultFiles(parentId: nil, filter: FilterType.photoVideo, sort: FileSortOptions.newestToOldest).first
        }
    }
    
    private func listenToshouldReloadFiles() {
        self.mainAppModel?.vaultFilesManager?.shouldReloadFiles.sink(receiveValue: { shouldReloadVaultFiles in
            if (shouldReloadVaultFiles) {
                self.updateLastItem()
            }
        }).store(in: &cancellable)
    }
    
    func saveImage() {
        
        guard let mainAppModel, let imageData else { return }
        let isPreserveMetadataOn = mainAppModel.settings.preserveMetadata

        if currentLocation != nil && isPreserveMetadataOn {
            let url = mainAppModel.vaultManager.createTempFileURL(pathExtension: FileExtension.heic.rawValue)
            let isSaved = imageData.save(withLocation: currentLocation, fileURL: url)
            if isSaved {
                saveFile(urlFile: url)
            } else {
                displayError()
            }
        } else {
            guard let url = mainAppModel.vaultManager.saveDataToTempFile(data: imageData, pathExtension: FileExtension.heic.rawValue) else {
                displayError()
                return
            }
            saveFile(urlFile: url)
        }
    }
    
    func displayError() {
        shouldShowToast = true
        errorMessage = LocalizableCommon.commonError.localized
        shouldShowToast = false
    }
    
    func saveVideo() {
        guard let videoURL = videoURL else { return }
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
        
        let importedFiles = ImportedFile(urlFile: urlFile,
                                         parentId: self.rootFile?.id, 
                                         fileSource: FileSource.camera)
        
        self.mainAppModel?.vaultFilesManager?.addVaultFile(importedFiles: [importedFiles])
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
        let isPreserveMetadataOn = mainAppModel?.settings.preserveMetadata ?? false
        
        let importedFile = ImportedFile(urlFile: urlFile,
                                        parentId: self.rootFile?.id, 
                                        shouldPreserveMetadata: isPreserveMetadataOn,
                                        fileSource: .camera)
        
        self.mainAppModel?.addVaultFile(importedFiles:[importedFile],
                                        shouldReloadVaultFiles : self.shouldReloadVaultFiles,
                                        autoUpload: autoUpload)
    }
    
    private func handleSuccessAddingFiles(vaultFiles:[VaultFileDB]) {
        self.updateResultFile(vaultFiles:vaultFiles)
    }
    
    private func updateProgress(importProgress:ImportProgress) {
        DispatchQueue.main.async {
            self.progressFile.progress = importProgress.progress.value
            self.progressFile.progressFile = importProgress.progressFile.value
            self.progressFile.isFinishing = importProgress.isFinishing.value
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
        self.formattedCurrentTime = currentTime.formattedAsHHMMSS()
    }
    
    // MARK: - Private functions
    @objc private func timerRunning() {
        currentTime = currentTime + 1
        self.formattedCurrentTime = currentTime.formattedAsHHMMSS()
    }
}
