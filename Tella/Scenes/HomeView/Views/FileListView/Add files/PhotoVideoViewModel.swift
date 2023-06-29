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

    /// This function imports the video file from the user selected video with the withmetadata attached to the file
    /// - Parameters:
    ///   - files: Array of the URL of the videos
    ///   - type: Type of file
    func addVideoWithExif(files: [URL], type: TellaFileType) {
        Task {
            
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
    }
    
    /// This function imports the video file from the user selected video with the without metadata attached to the file
    /// - Parameters:
    ///   - files: Array of the URL of the videos
    ///   - type: Type of file
    func addVideoWithoutExif(files: [URL], type: TellaFileType) {
        files.forEach { file in
            let tmpFileURL = self.mainAppModel.vaultManager.createTempFileURL(pathExtension: file.pathExtension)
            Task {
                do {
                    guard let url = await file.exportFile(destinationURL: tmpFileURL) else { return }
                    let vaultFile = try await self.mainAppModel.add(files: [url],
                                                                    to: self.mainAppModel.vaultManager.root,
                                                                    type: type,
                                                                    folderPathArray: self.folderPathArray)

                    if self.mainAppModel.importOption == .deleteOriginal {
                        self.removeFiles(files: files)
                    }
                    DispatchQueue.main.async {
                        self.resultFile?.wrappedValue = vaultFile
                    }
                }
                catch {

                }
            }
        }
    }

    /// This function imports the image file from the user selected image with the metadata attached to the file
    /// - Parameters:
    ///   - image: The UIImage of the image file selected
    ///   - type: Type of the file that is selected
    ///   - pathExtension: File extension
    ///   - originalUrl: The original URL of the image file
    ///   - acturalURL:  The actual URL of the image file
    func addImageWithExif(image: UIImage , type: TellaFileType, pathExtension:String?, originalUrl: URL?, actualURL: URL?) {
        guard let data = image.pngData(), let actualURL = actualURL else { return }
        let methodExifData = actualURL.getEXIFData()
        Task {
            let exifData = await data.saveImageWithImageData(properties: methodExifData as NSDictionary)
            guard let url = mainAppModel.vaultManager.saveDataToTempFile(data: exifData as Data, pathExtension: pathExtension ?? "png") else { return  }
            do {
                let vaultFile = try await self.mainAppModel.add(files: [url],
                                                                to: self.mainAppModel.vaultManager.root,
                                                                type: type,
                                                                folderPathArray: self.folderPathArray)

                //remove originalURL from phone
                if mainAppModel.importOption == .deleteOriginal {
                    let imageUrls = [originalUrl].compactMap{$0}
                    removeOriginalImage(imageUrls: imageUrls)

                }
                DispatchQueue.main.async {
                    self.resultFile?.wrappedValue = vaultFile
                }
            }
            catch {

            }
        }
    }

    /// This function imports the image file from the user selected image without the metadata attached to the file
    /// - Parameters:
    ///   - image: The UIImage of the file
    ///   - type: This helps to determine the file type based on enum FileType
    ///   - pathExtension: Pathextension as  file extension
    ///   - originalUrl: The original URL of the image file
    func addImageWithoutExif(image: UIImage , type: TellaFileType, pathExtension:String?, originalUrl: URL?) {
        guard let data = image.fixedOrientation()?.pngData() else { return }
        guard let url = mainAppModel.vaultManager.saveDataToTempFile(data: data, pathExtension: pathExtension ?? "png") else { return  }
        Task {
            do {
                let vaultFile = try await self.mainAppModel.add(files: [url],
                                                                to: self.mainAppModel.vaultManager.root,
                                                                type: type,
                                                                folderPathArray: self.folderPathArray)

                //remove originalURL from phone

                if mainAppModel.importOption == .deleteOriginal {
                    let imageUrls = [originalUrl].compactMap{$0}
                    removeOriginalImage(imageUrls: imageUrls)

                }
                DispatchQueue.main.async {
                    self.resultFile?.wrappedValue = vaultFile
                }
            }
            catch {

            }
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

