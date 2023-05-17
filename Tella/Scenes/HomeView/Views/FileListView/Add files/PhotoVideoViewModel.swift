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
    func add(files: [URL], type: FileType) {
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
    func addVideoWithoutExif(files: [URL], type: FileType) {
        files.forEach { file in
            let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("\(Int(Date().timeIntervalSince1970))").appendingPathExtension(file.lastPathComponent)
            Task {
                do {
                    guard let url = await self.exportFile(url: file, destinationURL: tmpFileURL) else { return }
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
    func addWithExif(image: UIImage , type: FileType, pathExtension:String?, originalUrl: URL?, actualURL: URL?) {
        guard let data = image.pngData() else { return }
        let methodExifData = getEXIFData(url: actualURL!)
        Task {
            let exifData = await self.saveImageWithImageData(data: data, properties: methodExifData as NSDictionary)
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
    func add(image: UIImage , type: FileType, pathExtension:String?, originalUrl: URL?) {
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

    /// This function takes the image data and metadata as parameter and returns the image data with metadata
    /// - Parameters:
    ///   - data: The original image data
    ///   - properties: The metadata that is need to be written to the image data
    /// - Returns: The image data with metadata
    func saveImageWithImageData(data: Data, properties: NSDictionary) async -> NSData{

        let imageRef: CGImageSource = CGImageSourceCreateWithData((data as CFData), nil)!
        let uti: CFString = CGImageSourceGetType(imageRef)!
        let dataWithEXIF: NSMutableData = NSMutableData(data: data as Data)
        let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableData), uti, 1, nil)!

        CGImageDestinationAddImageFromSource(destination, imageRef, 0, (properties as CFDictionary))
        CGImageDestinationFinalize(destination)
        return dataWithEXIF
    }
    /// This function take the url of the video from the parameter converts it into AVAsset and exports the video file after removing the metadata to the destination URL and send the destination URL back .
    /// If there is any issue it will return nil
    /// - Parameters:
    ///   - url: URL of the video file
    ///   - destinationURL: The URL where the file without the metadata is saved
    /// - Returns: The URL in which the file is saved or if there is any issue then it will return nil
    func exportFile(url: URL, destinationURL: URL) async -> URL? {
        let asset = AVAsset(url: url)
        print(asset.metadata)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return nil }
        exportSession.outputURL = destinationURL
        var fileType: AVFileType = .mov
        if  url.pathExtension.lowercased() == "mov" {
            fileType = .mov
        } else if url.pathExtension.lowercased() == "mp4" {
            fileType = .mp4
        } else {
            fileType = .mov
        }
        exportSession.outputFileType = fileType
        exportSession.metadata = nil
        exportSession.metadataItemFilter = .forSharing()
        await exportSession.export()
        if exportSession.status == .completed {
            return destinationURL
        } else {
            return nil
        }
    }

    /// This function returns the EXIF or metadata as [String: Any] of the image using the URL that is passed as parameter
    /// - Parameter url: URL of the image source
    /// - Returns: Metadata
    func getEXIFData(url: URL) -> [String: Any] {
        let fileURL = url
        if let imageSource = CGImageSourceCreateWithURL(fileURL as CFURL, nil) {
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
            if let dict = imageProperties as? [String: Any] {
                print(dict)
                return dict
            }
        }
        return [:]
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
