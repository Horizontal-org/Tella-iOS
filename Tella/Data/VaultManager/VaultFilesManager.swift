//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class VaultFilesManager : VaultFilesManagerInterface {
    
    var shouldCancelImportAndEncryption = CurrentValueSubject<Bool,Never>(false)
    var vaultDataSource : VaultDataSourceInterface?
    var vaultManager : VaultManagerInterface?
    var cancellable: Set<AnyCancellable> = []
    
    init(key: String?, vaultManager: VaultManagerInterface? = nil) {
        self.vaultDataSource = VaultDataSource(key: key)
        self.vaultManager = vaultManager
    }
    
    func addVaultFile(filePaths: [URL], parentId: String?) -> AnyPublisher<ImportVaultFileResult,Never> {
        
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
                
                guard let isSaved = self.vaultManager?.save(fileDetail.data, vaultFileId: fileDetail.file.id) else { return }
               
                if isSaved {
                    do {
                        try self.vaultDataSource?.addVaultFile(file: fileDetail.file, parentId: parentId)
                    } catch let error {
                        debugLog(error)
                     }
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
    }
    
    func getFileDetailsStream(_ filePaths: [URL]) -> AsyncStream<VaultFileDetails> {
        
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
    }
    
    func addVaultFiles(files: [(VaultFileDB,String?)]) throws {
      
//        var result : Result<Bool,Error> = .success(true)
        
        try files.forEach { (file, parentId) in
             try self.vaultDataSource?.addVaultFile(file: file, parentId: parentId)
        }
        
//        return result
    }
    
    func addFolderFile(name: String, parentId: String?) {
        do {

            let file = VaultFileDB(type: .directory, name: name)
            try self.vaultDataSource?.addVaultFile(file: file, parentId: parentId)

        } catch let error {
            debugLog(error)
         }
    }
    
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB] {
        return self.vaultDataSource?.getVaultFiles(parentId: parentId, filter: filter, sort: sort) ?? []
    }
    
    
    func getFileDetails(filePath: URL) async throws -> VaultFileDetails?  {
        
        let id = UUID().uuidString
        let _ = filePath.startAccessingSecurityScopedResource()
        defer { filePath.stopAccessingSecurityScopedResource() }
        
        let data = try Data(contentsOf: filePath)
        
        async let thumnail = await filePath.thumbnail()
        
        let fileName = filePath.deletingPathExtension().lastPathComponent
        let path = filePath.path
        let pathExtension = filePath.pathExtension
        
        var width : Double?
        var height :  Double?
        
        if let resolution = filePath.resolution()  {
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
        return (VaultFileDetails(file: vaultFile, data: data))
    }
    
    func getFilesTotalSize(filePaths: [URL]) -> Int  {
        
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
        return self.vaultDataSource?.getVaultFile(id: id)
    }
    
    func getVaultFiles(ids: [String]) -> [VaultFileDB] {
        return self.vaultDataSource?.getVaultFiles(ids: ids) ?? []
    }
    
    func getRecentVaultFiles() -> [VaultFileDB] {
        return self.vaultDataSource?.getRecentVaultFiles() ?? []
        
    }
    
    
    func renameVaultFile(id: String?, name: String?) {
        self.vaultDataSource?.renameVaultFile(id: id, name: name)
    }
    
    func moveVaultFile(fileIds: [String], newParentId: String?) {
        self.vaultDataSource?.moveVaultFile(fileIds: fileIds, newParentId: newParentId)
    }
    
    func deleteVaultFile(fileIds ids: [String]) {
        self.vaultManager?.deleteVaultFile(filesIds: ids)
        self.vaultDataSource?.deleteVaultFile(ids: ids)
    }
    
    func deleteVaultFile(vaultFiles : [VaultFileDB]) {
        var resultFiles : [VaultFileDB] = []
        let fileWalker = FileWalker(vaultDataSource: self.vaultDataSource)
        
        vaultFiles.forEach { file in
            if file.type == .directory {
                resultFiles.append(contentsOf: fileWalker.walkWithDirectories(root: file))
            }
            resultFiles.append(file)
        }
        
        let fileIds = resultFiles.compactMap({$0.id})
        
        
        self.vaultManager?.deleteVaultFile(filesIds: fileIds)
        self.vaultDataSource?.deleteVaultFile(ids: fileIds)
    }
    
    
    func deleteAllVaultFiles() {
        self.vaultManager?.deleteAllVaultFilesFromDevice()
        self.vaultDataSource?.deleteAllVaultFiles()
    }
    
    func cancelImportAndEncryption() {
        self.shouldCancelImportAndEncryption.send(true)
    }
    
}