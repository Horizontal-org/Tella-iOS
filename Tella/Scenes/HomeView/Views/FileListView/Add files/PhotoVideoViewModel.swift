//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Photos
import AVFoundation
import AVKit
import AssetsLibrary
import Combine


class ProgressFile:ObservableObject {
    @Published var progressFile : String = ""
    @Published var progress : Double = 0.0
    @Published var isFinishing  : Bool = false
}


class PhotoVideoViewModel : ObservableObject {
    
    var mainAppModel : MainAppModel
    var folderPathArray: [VaultFileDB] = []
    
    var  resultFile : Binding<[VaultFileDB]?>?
    var  rootFile : Binding<VaultFileDB?>?
    var  shouldReloadVaultFiles : Binding<Bool>?
    var shouldShowProgressView : Bool {
        return resultFile != nil
    }
    var shouldDeleteOriginal : Bool {
        return self.mainAppModel.importOption == .deleteOriginal
    }
    
    private var cancellable: Set<AnyCancellable> = []
    
    @Published var progressFile:ProgressFile = ProgressFile()
    
    
    init(mainAppModel: MainAppModel,
         folderPathArray: [VaultFileDB],
         resultFile : Binding<[VaultFileDB]?>?,
         rootFile : Binding<VaultFileDB?>?,
         shouldReloadVaultFiles : Binding<Bool>?) {
        self.mainAppModel = mainAppModel
        self.folderPathArray = folderPathArray
        self.resultFile = resultFile
        self.rootFile = rootFile
        self.shouldReloadVaultFiles = shouldReloadVaultFiles
    }
    
    /// To handle adding the image based on either the user want to preserve the metadata or not
    /// - Parameter completion: Object which contains all the information needed when the user selects a image from Gallery
    func handleAddingFile(_ completion: ImagePickerCompletion?) {
        
        Task {
            guard let completion , let mediaURL = completion.mediaURL else {return}
            
            let isPreserveMetadataOn = mainAppModel.settings.preserveMetadata
            
            let url : URL?
            
            if isPreserveMetadataOn {
                url = mediaURL
                
            } else {
                
                if completion.type == .image {
                    guard let data = mediaURL.contents()?.byRemovingEXIF() else {return}
                    url = mainAppModel.vaultManager.saveDataToTempFile(data: data, pathExtension: mediaURL.pathExtension)
                    mainAppModel.vaultManager.deleteFiles(files: [mediaURL])
                } else {
                    let tmpFileURL = self.mainAppModel.vaultManager.createTempFileURL(pathExtension: mediaURL.pathExtension)
                    url = await mediaURL.returnVideoURLWithoutMetadata(destinationURL: tmpFileURL)
                    mainAppModel.vaultManager.deleteFiles(files: [mediaURL])
                }
            }
            guard let url else { return }
            let importedFile = ImportedFile(urlFile: url, originalUrl: completion.referenceURL)
            addFiles(importedFiles: [importedFile])
        }
    }
    
    
    /// The function adds the file to the vault
    /// - Parameters:
    ///   - files:  Array of the URL of the videos
    ///   - type: Type of file
    func addFiles(importedFiles: [ImportedFile]?) {
        
        guard let importedFiles else { return }
        
        if shouldShowProgressView {
            addVaultFileWithProgressView(importedFiles:importedFiles)
        } else {
            addVaultFileInBackground(importedFiles:importedFiles)
        }
    }
    
    func addDocuments(urls:[URL]) {
        let importedFiles = urls.compactMap({ImportedFile(urlFile: $0,originalUrl: nil)})
        addFiles(importedFiles: importedFiles)
    }
    
    private func addVaultFileWithProgressView(importedFiles: [ImportedFile]) {

        self.mainAppModel.vaultFilesManager?.addVaultFile(importedFiles: importedFiles, parentId: self.rootFile?.wrappedValue?.id,deleteOriginal: shouldDeleteOriginal)
            .sink { importVaultFileResult in
                
                switch importVaultFileResult {
                case .fileAdded(let vaultFiles):
                    self.handleSuccessAddingFiles(vaultFiles: vaultFiles)
                case .importProgress(let importProgress):
                    self.updateProgress(importProgress:importProgress)
                }
                
            }.store(in: &cancellable)
    }
    
    private func addVaultFileInBackground(importedFiles: [ImportedFile]) {
        self.mainAppModel.addVaultFile(importedFiles: importedFiles, parentId: self.rootFile?.wrappedValue?.id, shouldReloadVaultFiles : self.shouldReloadVaultFiles,deleteOriginal: shouldDeleteOriginal)
    }
    
    private func handleSuccessAddingFiles(vaultFiles:[VaultFileDB] ) {
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
        }
    }
}

