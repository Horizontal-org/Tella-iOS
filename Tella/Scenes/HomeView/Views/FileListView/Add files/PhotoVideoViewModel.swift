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
    
    //TODO: Dhekra
    
    //    func handleAddingFile(_ imagePickerCompletion: ImagePickerCompletion?) {
    //        let isPreserveMetadataOn = mainAppModel.settings.preserveMetadata
    //        if let completion = imagePickerCompletion {
    //
    //            switch completion.type {
    //            case .video:
    //                self.handleAddingVideo(completion, isPreserveMetadataOn)
    //            case .image:
    //                self.handleAddingImage(completion, isPreserveMetadataOn)
    //            }
    //        }
    //    }
    //
    //    /// To handle adding the video based on either the user want to preserve the metadata or not
    //    /// - Parameters:
    //    ///   - completion: Object which contains all the information needed when the user selects a video from Gallery
    //    ///   - isPreserveMetadataOn: Flag to check whether the user want to preserve the metadata or not
    //    func handleAddingVideo(_ completion: ImagePickerCompletion, _ isPreserveMetadataOn: Bool) {
    //        if isPreserveMetadataOn{
    //            self.addVideoWithExif(completion)
    //        } else {
    //            self.addVideoWithoutExif(completion)
    //        }
    //    }
    /// To handle adding the image based on either the user want to preserve the metadata or not
    /// - Parameters:
    ///   - completion: Object which contains all the information needed when the user selects a image from Gallery
    ///   - isPreserveMetadataOn: Flag to check whether the user want to preserve the metadata or not
    func handleAddingFile(_ completion: ImagePickerCompletion?) {
        
        Task {
            guard let completion , let mediaURL = completion.mediaURL else {return}
            
            let isPreserveMetadataOn = mainAppModel.settings.preserveMetadata
            
            let url : URL?
            
            
            // add get url function
            
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
    
    //    /// This function imports the video file from the user selected video with the withmetadata attached to the file
    //    /// - Parameters:
    //    ///   - completion: Object which contains all the information needed when the user selects a image from Gallery
    //    func addVideoWithExif(_ completion: ImagePickerCompletion) {
    //        guard let url = completion.videoURL else { return }
    //        addFiles(files: [url], originalURLs: [completion.referenceURL])
    //    }
    //
    //    //    /// This function imports the document file
    //    //    /// - Parameters:
    //    //    ///   - files: Array of the URL of the videos
    //    //    func addDocument(files: [URL]) {
    //    //        Task {
    //    //            await handleAddVideoFile(files: files, type: .document, referenceUrl: nil)
    //    //        }
    //    //    }
    //
    //    /// This function imports the video file from the user selected video with the without metadata attached to the file
    //    /// - Parameters:
    //    ///   - completion: Object which contains all the information needed when the user selects a image from Gallery
    //    func addVideoWithoutExif(_ completion: ImagePickerCompletion) {
    //        Task {
    //            if let url = completion.videoURL {
    //                let files = [url]
    //                let urls = await files.asyncMap({ file in
    //                    let tmpFileURL = self.mainAppModel.vaultManager.createTempFileURL(pathExtension: file.pathExtension)
    //                    return await file.returnVideoURLWithoutMetadata(destinationURL: tmpFileURL)
    //                })
    //                //                await handleAddVideoFile(files: urls.compactMap({$0}), type: .video, referenceUrl: completion.referenceURL)
    //                addFiles(files: urls.compactMap({$0}), originalURLs: [completion.referenceURL])
    //
    //            }
    //        }
    //    }
    
    /// The function adds the video file to the vault
    /// - Parameters:
    ///   - files:  Array of the URL of the videos
    ///   - type: Type of file
    func addFiles(files: [URL?], originalURLs: [URL?]? = nil) {
        
        let files = files.compactMap({$0})
        
        self.mainAppModel.addVaultFile(filePaths: files, parentId: self.rootFile?.wrappedValue?.id)
            .sink { importVaultFileResult in
                
                switch importVaultFileResult {
                    
                case .fileAdded(let vaulFile):
                    
                    if self.mainAppModel.importOption == .deleteOriginal {
                        
                        if let originalURLs {
                            self.removeOriginalImage(imageUrls: originalURLs)
                        } else {
                            self.removeFiles(files: files)
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
    
    //    /// This function imports the image file from the user selected image with the metadata attached to the file
    //    /// - Parameter completion: Object which contains all the information needed when the user selects a image from Gallery
    //    func addImageWithExif(completion: ImagePickerCompletion) async {
    //        guard let actualURL = completion.imageURL else { return }
    //        //        await self.handleAddingImageFile(files: [actualURL], originalURL: completion.referenceURL)
    //        addFiles(files: [actualURL], originalURLs: [completion.referenceURL])
    //
    //    }
    
    //    /// This function imports the image file from the user selected image with the without metadata attached to the file
    //    /// - Parameter completion: bject which contains all the information needed when the user selects a image from Gallery
    //    func addImageWithoutExif(completion: ImagePickerCompletion) async {
    //        guard let data = completion.image?.fixedOrientation()?.pngData() else { return }
    //        guard let url = mainAppModel.vaultManager.saveDataToTempFile(data: data, pathExtension: completion.pathExtension ?? "png") else { return }
    //        //        await self.handleAddingImageFile(files: [url], originalURL: completion.referenceURL)
    //
    //        addFiles(files: [url], originalURLs: [completion.referenceURL])
    //
    //    }
    
    //    /// The function adds the image file to the vault
    //    /// - Parameters:
    //    ///   - files: Array of the URL of the images
    //    ///   - originalURL: The actual URL of the image selected
    //    func handleAddingImageFile(files: [URL],originalURL: URL?) async {
    //
    //
    //        self.mainAppModel.addVaultFile(filePaths: files, parentId: self.rootFile?.wrappedValue?.id)
    //            .sink { importVaultFileResult in
    //
    //                switch importVaultFileResult {
    //                case .fileAdded(let vaulFile):
    //
    //                    break
    //
    //                case .importProgress(let importProgress):
    //                    print("importProgress", importProgress)
    //
    //                    break
    //
    //                }
    //
    //            }.store(in: &cancellable)
    //
    //
    //
    //
    //
    ////        do {
    ////            let vaultFile = try await self.mainAppModel.add(files: files,
    ////                                                            to: self.rootFile?.wrappedValue,
    ////                                                            type: .image,
    ////                                                            folderPathArray: self.folderPathArray)
    ////
    ////            //remove originalURL from phone
    ////            if mainAppModel.importOption == .deleteOriginal {
    ////                let imageUrls = [originalURL].compactMap{$0}
    ////                removeOriginalImage(imageUrls: imageUrls)
    ////
    ////            }
    ////            DispatchQueue.main.async {
    ////                self.resultFile?.wrappedValue = vaultFile
    ////            }
    ////        }
    ////        catch {
    ////
    ////        }
    //    }
    
    func removeOriginalImage(imageUrls: [URL?]) {
        //        guard let imageUrls  else { return  }
        let imageUrlss = imageUrls.compactMap({$0})
        PHPhotoLibrary.shared().performChanges( {
            let imageAssetToDelete = PHAsset.fetchAssets(withALAssetURLs: imageUrlss, options: nil)
            PHAssetChangeRequest.deleteAssets(imageAssetToDelete)
        },
                                                completionHandler: { success, error in
            print("Finished deleting asset. %@", (success ? "Success" : error as Any))
        })
    }
    
    func removeFiles(files: [URL]) {
        for file in files {
            do {
                try FileManager.default.removeItem(at: file)
            } catch {
                print("Error deleting file: \(error.localizedDescription)")
            }
        }
    }
}



//                guard lket data = completion.image?.fixedOrientation()?.pngData() else { return }
