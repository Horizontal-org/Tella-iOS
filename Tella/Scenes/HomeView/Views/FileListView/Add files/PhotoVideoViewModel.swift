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

class PhotoVideoViewModel : ObservableObject {
    
    var mainAppModel : MainAppModel
    var folderPathArray: [VaultFile] = []
    var  resultFile : Binding<[VaultFile]?>?
    
    init(mainAppModel: MainAppModel,
         folderPathArray: [VaultFile],
         resultFile : Binding<[VaultFile]?>? ) {
        
        self.mainAppModel = mainAppModel
        self.folderPathArray = folderPathArray
        self.resultFile = resultFile
    }


    func handleAddingFile(_ imagePickerCompletion: ImagePickerCompletion?) {
        let isPreserveMetadataOn = mainAppModel.settings.preserveMetadata
        if let completion = imagePickerCompletion {
           
            switch completion.type {
            case .video:
                self.handleAddingVideo(completion, isPreserveMetadataOn)
            case .image:
                self.handleAddingImage(completion, isPreserveMetadataOn)

            }
        }
    }

    /// To handle adding the video based on either the user want to preserve the metadata or not
    /// - Parameters:
    ///   - completion: Object which contains all the information needed when the user selects a video from Gallery
    ///   - isPreserveMetadataOn: Flag to check whether the user want to preserve the metadata or not
    func handleAddingVideo(_ completion: ImagePickerCompletion, _ isPreserveMetadataOn: Bool) {
        if let url = completion.videoURL {
            if isPreserveMetadataOn{
                self.addVideoWithExif(files: [url])
            } else {
                self.addVideoWithoutExif(files: [url])
            }
        }
    }
    /// To handle adding the image based on either the user want to preserve the metadata or not
    /// - Parameters:
    ///   - completion: Object which contains all the information needed when the user selects a image from Gallery
    ///   - isPreserveMetadataOn: Flag to check whether the user want to preserve the metadata or not
    func handleAddingImage(_ completion: ImagePickerCompletion, _ isPreserveMetadataOn: Bool) {
        Task {
            if isPreserveMetadataOn {
                await self.addImageWithExif(completion: completion)
            } else {
                await self.addImageWithoutExif(completion: completion)
            }
        }

    }

    /// This function imports the video file from the user selected video with the withmetadata attached to the file
    /// - Parameters:
    ///   - files: Array of the URL of the videos
    ///   - type: Type of file
    func addVideoWithExif(files: [URL]) {
        Task {
            await handleAddVideoFile(files: files, type: .video)
        }
    }
    /// This function imports the document file
    /// - Parameters:
    ///   - files: Array of the URL of the videos
    func addDocument(files: [URL]) {
        Task {
            await handleAddVideoFile(files: files, type: .document)
        }
    }

    /// This function imports the video file from the user selected video with the without metadata attached to the file
    /// - Parameters:
    ///   - files: Array of the URL of the videos
    ///   - type: Type of file
    func addVideoWithoutExif(files: [URL]) {
        Task {
            let urls = await files.asyncMap({ file in
                let tmpFileURL = self.mainAppModel.vaultManager.createTempFileURL(pathExtension: file.pathExtension)
                return await file.returnVideoURLWithoutMetadata(destinationURL: tmpFileURL)
            })
            await handleAddVideoFile(files: urls.compactMap({$0}), type: .video)
        }
    }

    /// The function adds the video file to the vault
    /// - Parameters:
    ///   - files:  Array of the URL of the videos
    ///   - type: Type of file
    func handleAddVideoFile(files: [URL], type: TellaFileType) async {

        do { let vaultFile = try await self.mainAppModel.add(files: files,
                                                             to: self.mainAppModel.vaultManager.root,
                                                             type: type,
                                                             folderPathArray: self.folderPathArray)

            if mainAppModel.importOption == .deleteOriginal {
                removeFiles(files: files)
            }
            DispatchQueue.main.async {
                self.resultFile?.wrappedValue = vaultFile
            }
        }
        catch {

        }
    }

    /// This function imports the image file from the user selected image with the metadata attached to the file
    /// - Parameter completion: Object which contains all the information needed when the user selects a image from Gallery
    func addImageWithExif(completion: ImagePickerCompletion) async {
        guard let actualURL = completion.imageURL else { return }
        await self.handleAddingImageFile(files: [actualURL], originalURL: completion.referenceURL)
    }

    /// This function imports the image file from the user selected image with the without metadata attached to the file
    /// - Parameter completion: bject which contains all the information needed when the user selects a image from Gallery
    func addImageWithoutExif(completion: ImagePickerCompletion) async {
        guard let data = completion.image?.fixedOrientation()?.pngData() else { return }
        guard let url = mainAppModel.vaultManager.saveDataToTempFile(data: data, pathExtension: completion.pathExtension ?? "png") else { return }
        await self.handleAddingImageFile(files: [url], originalURL: completion.referenceURL)
    }

    /// The function adds the image file to the vault
    /// - Parameters:
    ///   - files: Array of the URL of the images
    ///   - originalURL: The actual URL of the image selected
    func handleAddingImageFile(files: [URL],originalURL: URL?) async {
        do {
            let vaultFile = try await self.mainAppModel.add(files: files,
                                                            to: self.mainAppModel.vaultManager.root,
                                                            type: .image,
                                                            folderPathArray: self.folderPathArray)

            //remove originalURL from phone
            if mainAppModel.importOption == .deleteOriginal {
                let imageUrls = [originalURL].compactMap{$0}
                removeOriginalImage(imageUrls: imageUrls)

            }
            DispatchQueue.main.async {
                self.resultFile?.wrappedValue = vaultFile
            }
        }
        catch {

        }
    }

    func removeOriginalImage(imageUrls: [URL]) {
        PHPhotoLibrary.shared().performChanges( {
            let imageAssetToDelete = PHAsset.fetchAssets(withALAssetURLs: imageUrls, options: nil)
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

