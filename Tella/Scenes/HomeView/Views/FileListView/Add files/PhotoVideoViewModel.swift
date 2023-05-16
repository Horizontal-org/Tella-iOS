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
    
    func add(files: [URL], type: FileType) {
        Task {
            let asset: AVAsset = AVAsset(url: files.first!)
            asset.metadata.forEach { metadata in
                print(metadata.key)
                print(metadata.keySpace)
                
            }
            if #available(iOS 15, *) {
                for format in try await asset.load(.availableMetadataFormats) {
                    _ = try await asset.loadMetadata(for: format)
                    // Process the format-specific metadata collection.
                }
            } else {
                // Fallback on earlier versions
            }
        }
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
    
    func addWithExif(image: UIImage , type: FileType, pathExtension:String?, originalUrl: URL?, acturalURL: URL?) {
        guard let data = image.fixedOrientation()?.pngData() else { return }
        let methodExifData = getEXIFData(url: acturalURL!)
        Task {
            let exifData = await self.saveImageWithImageData(data: data, properties: methodExifData as NSDictionary, pathExtension: pathExtension ?? "png")
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

    func add(image: UIImage , type: FileType, pathExtension:String?, originalUrl: URL?, acturalURL: URL?) {
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
    func saveImageWithImageData(data: Data, properties: NSDictionary, pathExtension: String) async -> NSData{

        let imageRef: CGImageSource = CGImageSourceCreateWithData((data as CFData), nil)!
        let uti: CFString = CGImageSourceGetType(imageRef)!
        let dataWithEXIF: NSMutableData = NSMutableData(data: data as Data)
        let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableData), uti, 1, nil)!

        CGImageDestinationAddImageFromSource(destination, imageRef, 0, (properties as CFDictionary))
        CGImageDestinationFinalize(destination)
        return dataWithEXIF
    }
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
extension Data {
    func byRemovingEXIF() -> Data? {
        guard let source = CGImageSourceCreateWithData(self as NSData, nil),
              let type = CGImageSourceGetType(source) else
        {
            return nil
        }
        let count = CGImageSourceGetCount(source)
        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(mutableData, type, count, nil) else {
            return nil
        }

        let exifToRemove: CFDictionary = [
            kCGImagePropertyExifDictionary: kCFNull,
            kCGImagePropertyGPSDictionary: kCFNull,
        ] as CFDictionary

        for index in 0 ..< count {
            CGImageDestinationAddImageFromSource(destination, source, index, exifToRemove)
            if !CGImageDestinationFinalize(destination) {
                print("Failed to finalize")
            }
        }

        return mutableData as Data
    }
}
