//
//  VaultFilesManagerExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/6/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import MobileCoreServices
import Photos

extension VaultFilesManager {
    
    func updateURL(importedFile:inout ImportedFile) async {
        
        do {
            
            var url : URL?
            guard let asset = importedFile.asset else {
                return
            }
            
            let mediaType = asset.mediaType
            
            if (importedFile.urlFile != nil && mediaType == .image) {
                return // Image data already saved into the temp fileURL
            }
            
            switch asset.mediaType {
            case .image:
                url = try await getImageUrlFromAsset(importedFile:importedFile)
            default:
                url = try await asset.getAVAssetUrl()
            }
            
            importedFile.urlFile = url
            
        } catch let error {
            debugLog(error)
            return
        }
    }
    
    func getImageUrlFromAsset(importedFile:ImportedFile) async throws -> URL? {
        
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
            await filePath = getUrlFromAsset(importedFile: importedFile)
            
        } else {
            await filePath = getModifiedUrlFromURL(importedFile: importedFile)
        }
        
        return filePath
    }
    
    func getModifiedUrlFromURL(importedFile:ImportedFile) async -> URL? {
        
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
                guard let tmpFileURL = await urlFile.returnVideoURLWithoutMetadata(destinationURL: tmpFileURL) else {return nil}
                return tmpFileURL
            default:
                return urlFile
            }
        }
    }
    
    func getUrlFromAsset(importedFile:ImportedFile) async -> URL? {
        
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
    
    func getModifiedAVAssetUrl(importedFile:ImportedFile) async throws -> URL? {
        
        guard let url = importedFile.urlFile else {
            throw RuntimeError("URL is nil")
        }
        
        if !(importedFile.shouldPreserveMetadata)   {
            
            let tmpFileURLOutput = self.vaultManager?.createTempFileURL(pathExtension: url.pathExtension)
            guard let tmpFileURLOutput else {
                throw RuntimeError("Error creating temp file URL")
            }
            
            guard let tmpFileURL = await url.returnVideoURLWithoutMetadata(destinationURL: tmpFileURLOutput) else {
                return url
            }
            return tmpFileURL
            
        } else {
            return url
        }
    }
}
