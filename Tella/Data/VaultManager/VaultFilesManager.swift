//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

protocol VaultFilesManagerInterface {
    
    func addVaultFile(filePaths: [URL], parentId: String?) -> AnyPublisher<ImportVaultFileResult,Never>
}



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
    
    func addVaultFile(filePaths: [URL], parentId: String?) -> AnyPublisher<ImportVaultFileResult,Never> {
        
        let filesActor = FilesActor()

        
        //        return Deferred {
        //            Future <ImportVaultFileResult,Never> {  [unowned  self] promise in
        
        let filestotalSize = self.getFilesTotalSize(filePaths: filePaths)
        self.progress.start(totalFiles: filePaths.count, totalSize: Double(filestotalSize))
        
        print("filestotalSize : ", filestotalSize)
        
        //                promise(.success(.importProgress(importProgress: self.progress)))
        
        let subject = CurrentValueSubject<ImportVaultFileResult, Never>(.importProgress(importProgress: self.progress))

        

        
        let queue = OperationQueue()
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
        
        for filePath in filePaths {
            
            queue.addOperation {
                
                Task {
                    // self?.progress.currentFile = index
                    
                    guard let fileDetail = try await self.getFileInfos(filePath: filePath) else {return}
                    
                    self.vaultDataSource?.addVaultFile(file: fileDetail.file, parentId: parentId)
                    self.importFileAndEncrypt(data: fileDetail.data, vaultFile: fileDetail.file)
                    
                    
                    
                    await filesActor.add(vaultFile: fileDetail.file)

 
                    if await filesActor.files.count == filePaths.count {
                        self.progress.finish()
                        subject.send(.importProgress(importProgress: self.progress))
                        await subject.send(.fileAdded(filesActor.files))
                    }
                    
                }
            }
            
            
        }
        
 
        
        self.shouldCancelImportAndEncryption.sink(receiveValue: { [unowned self] value in
            if value {
                // backgroundWorkItem?.cancel()
                queue.cancelAllOperations()
                self.progress.stop()
                self.shouldCancelImportAndEncryption.value = false
            }
            
        }).store(in: &self.cancellable)

        //        }.eraseToAnyPublisher()
        
        return subject.eraseToAnyPublisher()
    }
    
    
    
    func getFileInfos(filePath: URL) async throws -> VaultFileDetails?  {
        
        ///----------------------------------------
        let _ = filePath.startAccessingSecurityScopedResource()
        defer { filePath.stopAccessingSecurityScopedResource() }
        
        let data = try Data(contentsOf: filePath)
        
        async let thumnail = await filePath.thumbnail()
        let fileName = filePath.deletingPathExtension().lastPathComponent
        let containerName = UUID().uuidString
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
    
}
