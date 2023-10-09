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
            
            addFiles(files: [url], originalURLs: [completion.referenceURL])
        }
    }
    
    /// The function adds the file to the vault
    /// - Parameters:
    ///   - files:  Array of the URL of the videos
    ///   - type: Type of file
    func addFiles(files: [URL?], originalURLs: [URL?]? = nil) {
        
        let files = files.compactMap({$0})
        
        self.mainAppModel.vaultFilesManager?.addVaultFile(filePaths: files, parentId: self.rootFile?.wrappedValue?.id)
            .sink { importVaultFileResult in
                
                switch importVaultFileResult {
                    
                case .fileAdded(let vaulFile):
                    
                    if self.mainAppModel.importOption == .deleteOriginal {
                        
                        if let originalURLs {
                            self.removeOriginalImage(imageUrls: originalURLs)
                        } else {
                            self.deleteFiles(files: files)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.resultFile?.wrappedValue = vaulFile
                        self.shouldReloadVaultFiles?.wrappedValue = true
                    }
                    
                case .importProgress(let importProgress):
                    
                    DispatchQueue.main.async {
                        self.progressFile.progress = importProgress.progress.value
                        self.progressFile.progressFile = importProgress.progressFile.value
                        self.progressFile.isFinishing = importProgress.isFinishing.value
                    }
                }
                
            }.store(in: &cancellable)
    }
    
    func removeOriginalImage(imageUrls: [URL?]) {
        //        guard let imageUrls  else { return  }
        let imageUrlss = imageUrls.compactMap({$0})
        PHPhotoLibrary.shared().performChanges( {
            let imageAssetToDelete = PHAsset.fetchAssets(withALAssetURLs: imageUrlss, options: nil)
            PHAssetChangeRequest.deleteAssets(imageAssetToDelete)
        },
                                                completionHandler: { success, error in
        })
    }
    
    func deleteFiles(files: [URL]) {
        mainAppModel.vaultManager.deleteFiles(files: files)
    }
}
