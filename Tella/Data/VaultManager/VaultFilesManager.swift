//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine




enum ImportVaultFileResult {
    
    case importProgress(importProgress:ImportProgress)
    case fileAdded([VaultFileDB])
    
}

actor FilesActor {
    
    var files : [VaultFileDB] = []
    
    func add(vaultFile: VaultFileDB) {
        files.append(vaultFile)
    }
}

extension VaultManager : VaultFilesManagerInterface {
    

    func addVaultFile(filePaths: [URL], parentId: String?) -> AnyPublisher<ImportVaultFileResult,Never> { // ✅
        
        let filesActor = FilesActor()
        let importProgress :  ImportProgress = ImportProgress()
        
        let subject = CurrentValueSubject<ImportVaultFileResult, Never>(.importProgress(importProgress:  importProgress))
        
        let filestotalSize = self.getFilesTotalSize(filePaths: filePaths)
         importProgress.start(totalFiles: filePaths.count, totalSize: Double(filestotalSize))

        let fileDetailsStream = self.getFileDetailsStream(filePaths)
       
        Task {
            
            for await fileDetail in fileDetailsStream {
                
                if self.shouldCancelImportAndEncryption.value {
                     importProgress.stop()
                    self.shouldCancelImportAndEncryption.value = false
                    await subject.send(.fileAdded(filesActor.files))
                    return
                }
                
                guard let isSaved = self.save(fileDetail.data, vaultFile: fileDetail.file) else { return }
                if isSaved {
                    self.vaultDataSource?.addVaultFile(file: fileDetail.file, parentId: parentId)
                }
                
                await filesActor.add(vaultFile: fileDetail.file)

                if await filesActor.files.count == filePaths.count {
                     importProgress.finish()
                    await subject.send(.fileAdded(filesActor.files))
                } else {
                     importProgress.currentFile += 1
                }
                
                subject.send(.importProgress(importProgress:  importProgress))
            }
        }
        
         importProgress.progress.sink { progress in
            subject.send(.importProgress(importProgress:  importProgress))
        }.store(in: &self.cancellable)

        return subject.eraseToAnyPublisher()
    }  // ✅

    private func getFileDetailsStream(_ filePaths: [URL]) -> AsyncStream<VaultFileDetails> {  // ✅
        
        // Init AsyncStream with element type = `VaultFileDetails`
        let stream = AsyncStream(VaultFileDetails.self) { continuation in
            
            Task { [weak self] in
                for filePath in filePaths {
                    
                    // Get File Details
                    guard let fileDetails = try await self?.getFileDetails(filePath: filePath) else { return }
                    
                    // Yield the element (Get File Details) when getFileInfos is completed
                    continuation.yield(fileDetails)
                }
                
                // All files are ready
                // Call the continuation’s finish() method when there are no further elements to produce
                continuation.finish()
            }
        }
        
        return stream
    }  // ✅

    func addFolderFile(name: String, parentId: String?) { // ✅
        let file = VaultFileDB(type: .directory, name: name)
        self.vaultDataSource?.addVaultFile(file: file, parentId: parentId)
    } // ✅
    
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB] { // ✅
        return self.vaultDataSource?.getVaultFiles(parentId: parentId, filter: filter, sort: sort) ?? []
    } // ✅
    
    
    func getFileDetails(filePath: URL) async throws -> VaultFileDetails?  { // ✅
        
        ///----------------------------------------
        let _ = filePath.startAccessingSecurityScopedResource()
        defer { filePath.stopAccessingSecurityScopedResource() }
        
        let data = try Data(contentsOf: filePath)
        
        async let thumnail = await filePath.thumbnail()
        let fileName = filePath.deletingPathExtension().lastPathComponent
        let path = filePath.path
        let pathExtension = filePath.pathExtension
        let resolution = filePath.resolution()
        let duration =  filePath.getDuration()
        let size = FileManager.default.sizeOfFile(atPath: path) ?? 0
        
        let vaultFile = await VaultFileDB(type: .file,
                                          hash: "",
                                          metadata: nil,
                                          thumbnail: thumnail,
                                          name: fileName,
                                          duration: duration,
                                          anonymous: true,
                                          size: size,
                                          mimeType: pathExtension.mimeType())
        
        
        ///-----------------------------------------
        
        
        return (VaultFileDetails(file: vaultFile, data: data))
    } // ✅
    
    func getFilesTotalSize(filePaths: [URL]) -> Int  { // ✅
        
        var totalSizeArray : [Int] = []
        
        for filePath in filePaths {
            
            let _ = filePath.startAccessingSecurityScopedResource()
            defer { filePath.stopAccessingSecurityScopedResource() }
            
            let size = FileManager.default.sizeOfFile(atPath: filePath.path) ?? 0
            totalSizeArray.append(size)
        }
        
        return totalSizeArray.reduce(0, +)
        
    } // ✅

    
    func getVaultFile(id: String?) -> VaultFileDB? {
        return self.vaultDataSource?.getVaultFile(id: id)
    }
    
    func getVaultFiles(ids: [String]) -> [VaultFileDB] {
        return self.vaultDataSource?.getVaultFiles(ids: ids) ?? []
    }
    
    func getRecentVaultFiles() -> [VaultFileDB] {
        return self.vaultDataSource?.getRecentVaultFiles() ?? []

    }

    
    func renameVaultFile(id: String, name: String?) {
        self.vaultDataSource?.renameVaultFile(id: id, name: name)
    }
    
    func moveVaultFile(fileIds: [String], newParentId: String?) {
        self.vaultDataSource?.moveVaultFile(fileIds: fileIds, newParentId: newParentId)
    }
    
     func deleteVaultFile(fileIds ids: [String]) {
        self.deleteVaultFile(filesIds: ids)
        self.vaultDataSource?.deleteVaultFile(ids: ids)
    }
}
