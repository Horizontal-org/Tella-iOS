//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class VaultFilesManager :ObservableObject, VaultFilesManagerInterface {
    
    var shouldCancelImportAndEncryption = CurrentValueSubject<Bool,Never>(false)
    var vaultDataBase : VaultDataBaseProtocol
    
    var vaultManager : VaultManagerInterface?
    var cancellable: Set<AnyCancellable> = []
    
    var shouldReloadFiles = CurrentValueSubject<Bool, Never>(false)
    
    init(vaultDataBase: VaultDataBaseProtocol, vaultManager: VaultManagerInterface? = nil) throws {
        self.vaultDataBase = vaultDataBase
        self.vaultManager = vaultManager
    }
    
    func addVaultFile( importedFiles:  [ImportedFile]) -> AnyPublisher<ImportVaultFileResult,Never> {
        
        let importProgress :  ImportProgress = ImportProgress()
        let subject = CurrentValueSubject<ImportVaultFileResult, Never>(.importProgress(importProgress:  importProgress))
        
        Task {
            
            var importedFiles = importedFiles
            
            await updateImportedFilesURLs(&importedFiles)
            let filePaths = importedFiles.compactMap({$0.urlFile})
            let filestotalSize = self.getFilesTotalSize(filePaths: filePaths)
            
            importProgress.start(totalFiles: filePaths.count, totalSize: Double(filestotalSize))
            
            let fileDetailsStream = self.getFileDetailsStream(importedFiles)
            
            await processFileDetailsStream(fileDetailsStream,
                                           importProgress: importProgress,
                                           subject: subject,
                                           importedFiles: importedFiles)
        }
        
        importProgress.progress.sink { progress in
            subject.send(.importProgress(importProgress:  importProgress))
        }.store(in: &self.cancellable)
        
        return subject.eraseToAnyPublisher()
    }
    
    private func updateImportedFilesURLs(_ importedFiles: inout [ImportedFile]) async {
        for index in importedFiles.indices {
            await updateURL(importedFile: &importedFiles[index])
        }
    }
    
    private func processFileDetailsStream(_ fileDetailsStream: AsyncStream<VaultFileDetails>,
                                          importProgress: ImportProgress,
                                          subject: CurrentValueSubject<ImportVaultFileResult, Never>,
                                          importedFiles: [ImportedFile]) async {
        
        let filesActor = FilesActor()
        
        for await fileDetail in fileDetailsStream {
            
            if self.shouldCancelImportAndEncryption.value {
                importProgress.stop()
                self.shouldCancelImportAndEncryption.value = false
                await subject.send(.fileAdded(filesActor.files))
                return
            }
            
            guard let filePath = await getModifiedURL(importedFile: fileDetail.importedFile),
                  let isSaved = self.vaultManager?.save(filePath, vaultFileId: fileDetail.file.id) else { return }
            
            if isSaved {
                self.vaultDataBase.addVaultFile(file: fileDetail.file, parentId: fileDetail.importedFile.parentId)
            }
            
            await filesActor.add(vaultFile: fileDetail.file)
            
            if await filesActor.files.count == importedFiles.count {
                importProgress.finish()
                await subject.send(.fileAdded(filesActor.files))
                handleDeletionFiles(importedFiles:importedFiles)
                shouldReloadFiles.send(true)
                
            } else {
                importProgress.currentFile += 1
            }
            
            subject.send(.importProgress(importProgress:  importProgress))
        }
    }
    
    func addVaultFile(fileDetail:VaultFileDetails) -> AnyPublisher<BackgroundActivityStatus,Never> {
        
        let subject = CurrentValueSubject<BackgroundActivityStatus, Never>(.inProgress)
        
        Task {
            
            guard
                let filePath = await getModifiedURL(importedFile: fileDetail.importedFile),
                let isSaved = self.vaultManager?.save(filePath, vaultFileId: fileDetail.file.id)
            else {
                subject.send(BackgroundActivityStatus.failed)
                return
            }
            
            if isSaved {
                handleDatabaseAddition(fileDetails: fileDetail,
                                       subject: subject)
            } else {
                subject.send(BackgroundActivityStatus.failed)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    private func handleDatabaseAddition(fileDetails:VaultFileDetails,
                                        subject : CurrentValueSubject<BackgroundActivityStatus, Never> ) {
        
        let result = self.vaultDataBase.addVaultFile(file: fileDetails.file, parentId: fileDetails.importedFile.parentId)
        
        switch result {
        case .success:
            
            guard let vaultFile = getVaultFile(id: fileDetails.file.id) else {
                subject.send(.failed)
                return
            }
            
            shouldReloadFiles.send(true)
            
            // Delete original file
            handleDeletionFiles(importedFiles:[fileDetails.importedFile])
            
            subject.send(.completed(vaultFile))
            
        case .failure:
            subject.send(.failed)
        }
    }
    
    private func getFileDetailsStream(_ importedFiles: [ImportedFile]) -> AsyncStream<VaultFileDetails> {
        
        // Init AsyncStream with element type = `VaultFileDetails`
        let stream = AsyncStream(VaultFileDetails.self) { continuation in
            
            Task { [weak self] in
                for filePath in importedFiles {
                    
                    // Get File Details
                    guard let fileDetails =  await self?.getFileDetails(importedFile: filePath) else { return }
                    
                    // Yield the element (Get File Details) when getFileInfos is completed
                    continuation.yield(fileDetails)
                }
                
                // All files are ready
                // Call the continuation’s finish() method when there are no further elements to produce
                continuation.finish()
            }
        }
        
        return stream
    }
    
    func addVaultFiles(files: [VaultFileDetailsToMerge]) throws {
        try files.forEach { fileDetails in
            let addVaultFileResult = self.vaultDataBase.addVaultFile(file: fileDetails.vaultFileDB, parentId: fileDetails.parentId)
            
            if case .failure = addVaultFileResult {
                throw RuntimeError("Error adding file")
            }
        }
    }
    
    func updateEncryptionVaultFile() {
        
        let nonUpdatedVaultFiles = self.vaultDataBase.getNonUpdatedEncryptionVaultFiles()
        nonUpdatedVaultFiles.forEach { file in
            autoreleasepool {
                guard let url = self.vaultManager?.loadVaultFileToURLOld(file: file), let fileID = file.id  else { return }
                guard let isSaved = self.vaultManager?.save(url, vaultFileId: fileID) else { return }
                if isSaved {
                    self.vaultDataBase.updateEncryptionVaultFile(id: fileID)
                }
            }
        }
    }
    
    func addFolderFile(name: String, parentId: String?) -> Result<Int,Error>? {
        let file = VaultFileDB(type: .directory, name: name)
        return self.vaultDataBase.addVaultFile(file: file, parentId: parentId)
    }
    
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB] {
        return self.vaultDataBase.getVaultFiles(parentId: parentId, filter: filter, sort: sort)
    }
    
    func getVaultFile(vaultFilesFolders: [VaultFileDB]) -> [VaultFileDB] {
        var resultFiles: [VaultFileDB] = []
        
        vaultFilesFolders.forEach { file in
            let fileWalker = FileWalker(vaultDatabase: self.vaultDataBase)
            resultFiles.append(contentsOf: fileWalker.walk(root: file))
        }
        return resultFiles
    }
    
    func getFileDetails(importedFile: ImportedFile) async -> VaultFileDetails?  {
        
        var importedFile = importedFile
        
        await updateURL(importedFile: &importedFile)
        
        guard let filePath = importedFile.urlFile  else {return nil}
        
        let id = UUID().uuidString
        let _ = filePath.startAccessingSecurityScopedResource()
        defer { filePath.stopAccessingSecurityScopedResource() }
        
        async let thumnail = await filePath.thumbnail()
        
        let fileName = filePath.deletingPathExtension().lastPathComponent
        let path = filePath.path
        let pathExtension = filePath.pathExtension
        
        var width : Double?
        var height :  Double?
        
        if let resolution = filePath.resolution() {
            width = resolution.width
            height = resolution.height
        }
        
        let duration =  filePath.getDuration()
        let size = FileManager.default.sizeOfFile(atPath: path) ?? 0
        
        let vaultFile = await VaultFileDB(id: id,
                                          type: .file,
                                          thumbnail: thumnail  ,
                                          name: fileName,
                                          duration: duration,
                                          size: size,
                                          mimeType: pathExtension.mimeType(),
                                          width: width,
                                          height: height)
        return (VaultFileDetails(file: vaultFile, importedFile: importedFile))
    }
    
    func getFilesTotalSize(filePaths: [URL]) -> Int {
        
        var totalSizeArray : [Int] = []
        
        for filePath in filePaths {
            
            let _ = filePath.startAccessingSecurityScopedResource()
            defer { filePath.stopAccessingSecurityScopedResource() }
            
            let size = FileManager.default.sizeOfFile(atPath: filePath.path) ?? 0
            totalSizeArray.append(size)
        }
        
        return totalSizeArray.reduce(0, +)
        
    }
    
    
    func getVaultFile(id: String?) -> VaultFileDB? {
        return self.vaultDataBase.getVaultFile(id: id)
    }
    
    func getVaultFiles(ids: [String]) -> [VaultFileDB] {
        return self.vaultDataBase.getVaultFiles(ids: ids)
    }
    
    func getRecentVaultFiles() -> [VaultFileDB] {
        return self.vaultDataBase.getRecentVaultFiles()
    }
    
    func renameVaultFile(id: String?, name: String?) -> Result<Bool, Error>? {
        self.vaultDataBase.renameVaultFile(id: id, name: name)
    }
    
    func moveVaultFile(fileIds: [String], newParentId: String?) -> Result<Bool, Error>? {
        self.vaultDataBase.moveVaultFile(fileIds: fileIds, newParentId: newParentId)
    }
    
    @discardableResult
    func deleteVaultFile(fileIds ids: [String]) -> Result<Bool, Error>? {
        self.vaultManager?.deleteVaultFile(filesIds: ids)
        return self.vaultDataBase.deleteVaultFile(ids: ids)
    }
    
    func deleteVaultFile(vaultFiles : [VaultFileDB]) -> Result<Bool, Error>? {
        var resultFiles : [VaultFileDB] = []
        let fileWalker = FileWalker(vaultDatabase: self.vaultDataBase)
        
        vaultFiles.forEach { file in
            if file.type == .directory {
                resultFiles.append(contentsOf: fileWalker.walkWithDirectories(root: file))
            }
            resultFiles.append(file)
        }
        
        let fileIds = resultFiles.compactMap({$0.id})
        
        self.vaultManager?.deleteVaultFile(filesIds: fileIds)
        return self.vaultDataBase.deleteVaultFile(ids: fileIds)
    }
    
    @discardableResult
    func deleteAllVaultFiles() -> Result<Bool, Error>? {
        self.vaultManager?.deleteAllVaultFilesFromDevice()
        return self.vaultDataBase.deleteAllVaultFiles()
    }
    
    func cancelImportAndEncryption() {
        self.shouldCancelImportAndEncryption.send(true)
    }
}


import Photos

extension VaultFilesManager {
    
    private func handleDeletionFiles(importedFiles: [ImportedFile])  {
        
        var assets : [PHAsset] = []
        var urlfiles : [URL?] = []
        
        importedFiles.forEach { importedFile in
            
            if importedFile.deleteOriginal {
                
                if let asset = importedFile.asset {
                    assets.append(asset)
                } else {
                    urlfiles.append(importedFile.urlFile)
                }
            }
        }
        self.removeOriginalImage(assets: assets)
        self.deleteFiles(urlfiles: urlfiles)
    }
    
    private func removeOriginalImage(assets: [PHAsset]) {
        if !assets.isEmpty {
            let localIdentifiers = assets.compactMap({$0.localIdentifier})
            PHPhotoLibrary.shared().performChanges( {
                let imageAssetToDelete = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers, options: nil)
                PHAssetChangeRequest.deleteAssets(imageAssetToDelete)
            },
                                                    completionHandler: { success, error in
            })
        }
    }
    
    private func deleteFiles(urlfiles: [URL?]) {
        if !urlfiles.isEmpty {
            let urlfiles = urlfiles.compactMap({$0})
            vaultManager?.deleteFiles(files: urlfiles)
        }
    }
}
