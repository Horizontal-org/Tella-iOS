//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class VaultFilesManager : VaultFilesManagerInterface {
    
    var shouldCancelImportAndEncryption = CurrentValueSubject<Bool,Never>(false)
    var vaultDataBase : VaultDataBaseProtocol
    
    var vaultManager : VaultManagerInterface?
    var cancellable: Set<AnyCancellable> = []
    
    init(vaultDataBase: VaultDataBaseProtocol, vaultManager: VaultManagerInterface? = nil) throws {
        self.vaultDataBase = vaultDataBase
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
                    self.vaultDataBase.addVaultFile(file: fileDetail.file, parentId: parentId)
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
        try files.forEach { (file, parentId) in
            let addVaultFileResult = self.vaultDataBase.addVaultFile(file: file, parentId: parentId)
            
            if case .failure = addVaultFileResult {
                throw RuntimeError("Error adding file")
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
