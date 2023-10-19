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
                    
                } else {
                    let tmpFileURL = self.mainAppModel.vaultManager.createTempFileURL(pathExtension: mediaURL.pathExtension)
                    url = await mediaURL.returnVideoURLWithoutMetadata(destinationURL: tmpFileURL)
                }
            }
            
            addFiles(urlfiles: [url], originalURLs: [completion.referenceURL])
        }
    }
    
    /// The function adds the file to the vault
    /// - Parameters:
    ///   - files:  Array of the URL of the videos
    ///   - type: Type of file
    func addFiles(urlfiles: [URL?], originalURLs: [URL?]? = nil) {
        
        let filteredURLfiles = urlfiles.compactMap({$0})
        
        self.mainAppModel.vaultFilesManager?.addVaultFile(filePaths: filteredURLfiles, parentId: self.rootFile?.wrappedValue?.id)
            .sink { importVaultFileResult in
                
                switch importVaultFileResult {
                    
                case .fileAdded(let vaultFile):
                    self.handleDeletionFiles(urlfiles: filteredURLfiles, originalURLs: originalURLs)
                    self.updateResultFile(vaultFiles:vaultFile)

                case .importProgress(let importProgress):
                    self.updateProgress(importProgress:importProgress)
                }
                
            }.store(in: &cancellable)
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
    
    private func handleDeletionFiles(urlfiles: [URL], originalURLs: [URL?]?)  {
        if self.mainAppModel.importOption == .deleteOriginal {
            
            if let originalURLs {
                self.removeOriginalImage(imageUrls: originalURLs)
            } else {
                self.deleteFiles(files: urlfiles)
            }
        }
    }
    
    private func removeOriginalImage(imageUrls: [URL?]) {
        //        guard let imageUrls  else { return  }
        let imageUrlss = imageUrls.compactMap({$0})
        PHPhotoLibrary.shared().performChanges( {
            let imageAssetToDelete = PHAsset.fetchAssets(withALAssetURLs: imageUrlss, options: nil)
            PHAssetChangeRequest.deleteAssets(imageAssetToDelete)
        },
                                                completionHandler: { success, error in
        })
    }
    
    private func deleteFiles(files: [URL]) {
        mainAppModel.vaultManager.deleteFiles(files: files)
    }
}
