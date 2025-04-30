//
//  VaultFilesManagerExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/6/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Photos

extension VaultFilesManager {
    
    func updateURL(importedFile:inout ImportedFile) async {
        
        do {
            guard let asset = importedFile.asset else {
                return
            }
            
            if (importedFile.urlFile != nil && asset.mediaType == .image) {
                return // Image data already saved into the temp fileURL
            }
            
            switch asset.mediaType {
            case .image:
                importedFile.urlFile = try await getImageUrlFromAsset(importedFile:importedFile)
            default:
                importedFile.urlFile = try await asset.getAVAssetUrl()
            }
            
        } catch let error {
            debugLog(error)
            return
        }
    }
    
    private func getImageUrlFromAsset(importedFile:ImportedFile) async throws -> URL? {
        
        guard let asset = importedFile.asset else {
            throw RuntimeError("Asset is nil")
        }
        
        var data = try await asset.getDataFromAsset()
        
        if !(importedFile.shouldPreserveMetadata) {
            guard let newData = data?.byRemovingEXIF() else { return nil}
            data = newData
        }
        
        guard let resource = asset.getAssetResource() else {
            throw RuntimeError("Error fetching asset resources")
        }
        
        let fileURL =  self.vaultManager?.saveDataToTempFile(data: data,
                                                             fileName: resource.originalFilename)
        
        return fileURL
    }
    
    func getModifiedURL(importedFile:ImportedFile) async -> URL? {
        
        var filePath : URL?
        
        if let _ = importedFile.asset {
            await filePath = getUrlFromAsset(importedFile: importedFile) // From photo library
            
        } else {
            await filePath = getModifiedUrlFromURL(importedFile: importedFile) // From files
        }
        
        return filePath
    }
    
    private func getModifiedUrlFromURL(importedFile:ImportedFile) async -> URL? {
        
        guard let urlFile = importedFile.urlFile else { return nil}
        
        if importedFile.shouldPreserveMetadata {
            return urlFile
        } else {
            let type = urlFile.fileType
            
            switch type {
            case .image:
                guard let data = urlFile.contents()?.byRemovingEXIF() else { return nil}
                let tempFileurl = vaultManager?.saveDataToTempFile(data: data, pathExtension: urlFile.pathExtension)
                vaultManager?.deleteTmpFiles(files: [urlFile])
                return tempFileurl
            case .video:
                guard let tmpFileURL = vaultManager?.createTempFileURL(pathExtension: urlFile.pathExtension) else {return nil}
                guard let tmpFileURL = await returnVideoURLWithoutMetadata(inputputURL: urlFile, outputURL: tmpFileURL) else {return nil}
                return tmpFileURL
            default:
                return urlFile
            }
        }
    }
    
    private func getUrlFromAsset(importedFile:ImportedFile) async -> URL? {
        
        do {
            guard let type = importedFile.asset?.mediaType  else {
                return nil
            }
            switch type {
            case .image:
                return importedFile.urlFile // Already modified
            default:
                return try await getModifiedAVAssetUrl(importedFile:importedFile)
            }
            
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    private func getModifiedAVAssetUrl(importedFile:ImportedFile) async throws -> URL? {
        
        guard let url = importedFile.urlFile else {
            throw RuntimeError("URL is nil")
        }
        
        if !(importedFile.shouldPreserveMetadata)   {
            
            let tmpFileURLOutput = self.vaultManager?.createTempFileURL(pathExtension: url.pathExtension)
            guard let tmpFileURLOutput else {
                throw RuntimeError("Error creating temp file URL")
            }
            
            guard let tmpFileURL = await returnVideoURLWithoutMetadata(inputputURL: url, outputURL: tmpFileURLOutput, phasset: importedFile.asset) else {
                return nil
            }
            return tmpFileURL
            
        } else {
            return url
        }
    }
    
    /**
     Asynchronously exports a video without metadata to a specified output URL.

     This function takes an optional `inputURL` or `PHAsset` to specify the source of the video. It exports the video at the highest quality to the specified `outputURL` while stripping all metadata. It also listens for a cancellation request during the export process, allowing the user to cancel the export.

     - Parameters:
       - inputputURL: Optional `URL` of the input video file. If not provided, the function will use the provided `PHAsset`.
       - outputURL: The `URL` where the exported video will be saved.
       - phasset: Optional `PHAsset` representing the video to export. If provided, this will be used as the input source instead of `inputputURL`.

     - Returns: An optional `URL` of the exported video. Returns `nil` if the export fails or is cancelled.

     - Behavior:
       - Uses the highest available export quality (`AVAssetExportPresetHighestQuality`).
       - Removes metadata from the video using `metadataItemFilter = .forSharing()` and setting `exportSession.metadata` to `nil`.
       - Supports cancellation of the export through a `shouldCancelVideoExport` flag.

     - Notes:
       - The function listens to the `shouldCancelVideoExport` publisher and cancels the export if set to `true`.
       - The function is asynchronous, so the export process will not block the main thread.
     */

    func returnVideoURLWithoutMetadata(inputputURL: URL? = nil, outputURL: URL, phasset:PHAsset? = nil) async -> URL? {
       
        guard let asset = await getAVAsset(inputputURL:inputputURL, phasset: phasset) else {return nil}
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return nil }
        exportSession.outputURL = outputURL
        exportSession.outputFileType =  inputputURL?.getAVFileType()
        exportSession.metadata = nil
        exportSession.metadataItemFilter = .forSharing()

        self.shouldCancelVideoExport.sink(receiveValue: { shouldCancel in
          if shouldCancel {
              self.shouldCancelVideoExport.value = false
              exportSession.cancelExport()
          }
        }).store(in: &self.cancellable)

        await exportSession.export()

        if exportSession.status == .completed {
            return outputURL
        } else {
            return nil
        }
    }
    
    func getAVAsset(inputputURL: URL? = nil, phasset:PHAsset? = nil) async  -> AVAsset? {
        do {
            if let phasset {
                return try await phasset.getAVAsset()
            } else {
                guard let inputputURL else  {return nil}
                let _ = inputputURL.startAccessingSecurityScopedResource()
                defer { inputputURL.stopAccessingSecurityScopedResource() }
                return AVAsset(url: inputputURL)
            }
        } catch {
            return nil
        }
    }


}
