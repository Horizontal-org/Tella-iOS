//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

protocol VaultManagerInterface {
    
    var containerPath: String { get }
    
    func load(name: String) -> VaultFile?
    func load(file: VaultFile) -> Data?
    func load(files vaultFiles: [VaultFile]) -> [URL]
    func loadFilesInfos(file vaultFile: VaultFile, offsetSize:Int ) -> VaultFileInfo?
    func save(_ data: Data, vaultFile: VaultFile, parent: VaultFile?) -> Bool?
    func save<T: Datable>(_ object: T, vaultFile: VaultFile, parent: VaultFile? ) -> Bool?
    func createNewFolder(name: String, parent: VaultFile?, folderPathArray : [VaultFile])
    func rename(file : VaultFile, parent: VaultFile?)
    func delete(files: [VaultFile], parent: VaultFile?)
    func removeAllFiles()
    func saveDataToTempFile(data: Data, pathExtension:String) -> URL?
    func saveDataToTempFile(data: Data?, fileName: String, pathExtension:String) -> URL?
}

class VaultManager: VaultManagerInterface, ObservableObject {
    
    func rename(file: VaultFile, parent: VaultFile?) {
        save(file: root)
    }
    
    
    let containerPath: String
    private let rootFileName: String
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let cryptoManager: CryptoManagerInterface
    private let fileManager: FileManagerInterface
    
    @Published var root: VaultFile
    @Published var tellaData : TellaData
    
    @Published var progress :  ImportProgress
    var shouldCancelImportAndEncryption = CurrentValueSubject<Bool,Never>(false)
    
    private var cancellable: Set<AnyCancellable> = []
    
    init(cryptoManager: CryptoManagerInterface, fileManager: FileManagerInterface, rootFileName: String, containerPath: String, progress :  ImportProgress) {
        self.cryptoManager = cryptoManager
        self.fileManager = fileManager
        self.rootFileName = rootFileName
        self.containerPath = containerPath
        self.progress = progress
        self.tellaData = TellaData(key: CryptoManager.shared.metaPrivateKey?.getString())
        
        root = VaultFile.rootFile(fileName: "..", containerName: rootFileName)
        
        
        do {
            try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            debugLog(error)
        }
    }
    
    func initFiles() -> AnyPublisher<Bool,Never> {
        return Deferred {
            
            Future <Bool,Never> {  [weak self] promise in
                guard let self = self else { return }
                Task {
                    self.initRoot()
                    self.root.updateIds()
                    await self.recoverFiles()
                    self.save(file: self.root)
                    self.clearTmpDirectory()
                    promise(.success(true))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func initRoot() {
        if let root = self.load(name: self.rootFileName) {
            self.root = root
        } else {
            self.save(file: self.root)
        }
    }
    
    func importFile(files: [URL], to parentFolder: VaultFile?, type: TellaFileType, folderPathArray : [VaultFile]) async throws -> [VaultFile] {
        //        Task {
        do{
            let filesInfo = try await self.getFilesInfo(files: files, folderPathArray: folderPathArray)
            
            self.progress.start(totalFiles: files.count, totalSize: filesInfo.1)
            
            let queue = DispatchQueue.global(qos: .background)
            
            var backgroundWorkItem : DispatchWorkItem?
            
            backgroundWorkItem = DispatchWorkItem { [weak self]  in
                for (index, item) in filesInfo.0.enumerated() {
                    if (backgroundWorkItem?.isCancelled)! {
                        break
                    }
                    self?.progress.currentFile = index
                    self?.importFileAndEncrypt(data: item.0, vaultFile: item.1, parentFolder: parentFolder, type: type, folderPathArray: folderPathArray)
                }
                if let root = self?.root {
                    self?.save(file: root)
                    
                }
                self?.progress.finish()
                
                backgroundWorkItem?.cancel()
                backgroundWorkItem = nil
            }
            
            queue.async(execute: backgroundWorkItem!)
            
            self.shouldCancelImportAndEncryption.sink(receiveValue: { [weak self] value in
                if value {
                    backgroundWorkItem?.cancel()
                    self?.progress.stop()
                    self?.shouldCancelImportAndEncryption.value = false
                }
                
            }).store(in: &self.cancellable)
            
            return filesInfo.0.compactMap{$0.1}
        }
        catch {
            return []
            
        }
        //        }
    }
    
    func importFile(audioFilePath: URL, to parentFolder: VaultFile?, type: TellaFileType, fileName: String, folderPathArray : [VaultFile]) async throws -> VaultFile? {
        
        debugLog("\(audioFilePath)", space: .files)
        
        let _ = audioFilePath.startAccessingSecurityScopedResource()
        defer { audioFilePath.stopAccessingSecurityScopedResource() }
        do {
            
            let data = try Data(contentsOf: audioFilePath)
            
            let fileExtension = audioFilePath.pathExtension
            
            let path = audioFilePath.path
            
            let duration =  audioFilePath.getDuration()
            let size = FileManager.default.sizeOfFile(atPath: path) ?? 0
            let containerName = UUID().uuidString
            let pathArray = folderPathArray.compactMap{$0.containerName}
            
            let vaultFile = VaultFile(type: audioFilePath.fileType,
                                      fileName: fileName,
                                      containerName: containerName,
                                      files: nil,
                                      thumbnail: nil,
                                      fileExtension: fileExtension,
                                      size:size,
                                      resolution: nil,
                                      duration: duration,
                                      pathArray: pathArray)
            
            
            
            if let _ = save(data, vaultFile: vaultFile, parent: parentFolder) {
                save(file: root)
            }
            
            return vaultFile
        } catch let error {
            debugLog(error)
            return nil
        }
        
    }
    
    private func importFileAndEncrypt(data : Data, vaultFile:VaultFile, parentFolder :VaultFile?, type: TellaFileType, folderPathArray : [VaultFile]?) {
        
        if let _ = self.save(data, vaultFile: vaultFile, parent: parentFolder) {
        }
    }
    
    func createNewFolder(name: String, parent: VaultFile?, folderPathArray : [VaultFile])  {
        debugLog("\(name)", space: .files)
        let pathArray = folderPathArray.compactMap{$0.containerName}
        let vaultFile = VaultFile(type: .folder, fileName: name, files: nil, pathArray: pathArray)
        parent?.add(file: vaultFile)
        save(file: root)
    }
    
    func move(files: [VaultFile], from originalParentFolder: VaultFile?, to newParentFolder: VaultFile?) {
        debugLog("moving files")
        
        files.forEach { file in
            debugLog("\(file.fileName)", space: .files)
            newParentFolder?.add(file: file)
            originalParentFolder?.remove(file: file)
        }
        save(file: root)
    }
    
    func load(name: String) -> VaultFile? {
        debugLog("\(name)", space: .files)
        
        let fileURL = containerURL(for: name)
        debugLog("loading \(fileURL)")
        do {
            let encryptedData = try Data(contentsOf: fileURL)
            if let decrypted = cryptoManager.decrypt(encryptedData) {
                return try decoder.decode(VaultFile.self, from: decrypted)
            } else {
                debugLog("file load failed \(name)")
            }
        } catch let error {
            debugLog(error)
        }
        return nil
    }
    
    func load(file vaultFile: VaultFile) -> Data? {
        debugLog("\(vaultFile)", space: .files)
        
        let fileURL = containerURL(for: vaultFile.containerName)
        guard let encryptedData = fileManager.contents(atPath: fileURL) else {
            return nil
        }
        return cryptoManager.decrypt(encryptedData)
    }
    
    func loadVideo(file vaultFile: VaultFile) -> URL? {
        
        let videoData = self.load(file: vaultFile)
        
        let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(vaultFile.fileName).appendingPathExtension(vaultFile.fileExtension)
        
        guard (fileManager.createFile(atPath: tmpFileURL, contents: videoData))
                
        else {
            return nil
        }
        return tmpFileURL
    }
    
    
    func load(files vaultFiles: [VaultFile]) -> [URL] {
        
        var tmpUrlArray : [URL] = []
        
        vaultFiles.forEach { vaultFile in
            if vaultFile.type != .folder {
                let data = self.load(file: vaultFile)
                
                let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(vaultFile.fileName).appendingPathExtension(vaultFile.fileExtension)
                
                if fileManager.createFile(atPath: tmpFileURL, contents: data) {
                    tmpUrlArray.append(tmpFileURL)
                }
            }
        }
        return tmpUrlArray
    }
    
    
    func loadFilesInfos(file vaultFile: VaultFile, offsetSize:Int ) -> VaultFileInfo? {
        
        if vaultFile.type != .folder {
            guard var data = self.load(file: vaultFile) else {return nil }
            
            guard let extractedData = (data.extract(size: offsetSize)) else {return nil }
            
            let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(vaultFile.fileName).appendingPathExtension(vaultFile.fileExtension)
            
            if fileManager.createFile(atPath: tmpFileURL, contents: extractedData) {
                return VaultFileInfo(vaultFile: vaultFile,data: extractedData,url: tmpFileURL)
            }
        }
        return nil
    }
    
    func save(file vaultFile: VaultFile) {
        debugLog("\(vaultFile)", space: .files)
        
        let fileURL = containerURL(for: vaultFile.containerName)
        do {
            let encodedData = try encoder.encode(vaultFile)
            if let encrypted = cryptoManager.encrypt(encodedData) {
                fileManager.createFile(atPath: fileURL, contents: encrypted)
            } else {
                debugLog("encryption failed")
            }
        } catch let error {
            debugLog("\(error)")
        }
        debugLog("saved: \(fileURL) \(vaultFile.containerName)")
    }
    
    func save(_ data: Data, vaultFile: VaultFile, parent: VaultFile?) -> Bool? {
        debugLog("\(data.count); \(vaultFile.type); \(vaultFile.fileName); \nparent:\(String(describing: parent))", space: .files)
        
        let fileURL = containerURL(for: vaultFile.containerName)
        guard let encrypted = cryptoManager.encrypt(data),
              fileManager.createFile(atPath: fileURL, contents: encrypted) else {
            debugLog("encryption failed \(String(describing: vaultFile.fileName))", level: .debug, space: .crypto)
            return nil
        }
        parent?.add(file: vaultFile)
        return true
    }
    
    func save<T: Datable>(_ object: T, vaultFile: VaultFile, parent: VaultFile? ) -> Bool? {
        guard let data = object.data else {
            return nil
        }
        return save(data, vaultFile: vaultFile, parent: parent)
    }
    
    func saveDataToTempFile(data: Data, pathExtension:String) -> URL? {
        let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("\(Date().getDate())").appendingPathExtension(pathExtension)
        
        guard (fileManager.createFile(atPath: tmpFileURL, contents: data))
                
        else {
            return nil
        }
        return tmpFileURL
    }
    
    func saveDataToTempFile(data: Data?, fileName: String, pathExtension:String) -> URL? {
        let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(fileName).appendingPathExtension(pathExtension)
        
        guard (fileManager.createFile(atPath: tmpFileURL, contents: data))
                
        else {
            return nil
        }
        return tmpFileURL
    }
    
    func removeAllFiles() {
        debugLog("", space: .files)
        delete(files: root.files, parent: root)
        root = VaultFile.rootFile(fileName: "..", containerName: rootFileName)
        save(file: root)
    }
    
    func delete(files: [VaultFile], parent: VaultFile?) {
        for file in files {
            debugLog("\(file)", space: .files)
            if file.type == .folder {
                if file.files.count > 0 {
                    delete(files: file.files, parent: file)
                }
                parent?.remove(file: file)
            } else {
                delete(file: file, parent: parent)
            }
        }
        save(file: root)
    }
    
    func delete(file: VaultFile, parent: VaultFile?) {
        parent?.remove(file: file)
        
        let fileURL = containerURL(for: file.containerName)
        fileManager.removeItem(at: fileURL)
    }
    
    func clearTmpDirectory() {
        let tmpDirectory =  fileManager.contentsOfDirectory(atPath: NSTemporaryDirectory())
        tmpDirectory.forEach {[unowned self] file in
            let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
            fileManager.removeItem(at: path)
        }
    }
    
    private func containerURL(for containerName: String) -> URL {
        return containerURL.appendingPathComponent(containerName)
    }
    
    private var containerURL: URL {
        
        let url = FileManager.default.urls(for: .documentDirectory,
                                           in: .userDomainMask)[0].appendingPathComponent(containerPath)
        return url
    }
    
    private func getFilesInfo(files: [URL], folderPathArray:[VaultFile]) async throws ->([(Data,VaultFile)], Double)  {
        
        var totalSizeArray : [Double] = []
        var vaultFileArray : [(Data,VaultFile)] = []
        
        try await withThrowingTaskGroup(of: (Data,VaultFile).self, body: { group in
            
            for filePath in files {
                group.addTask {
                    
                    let _ = filePath.startAccessingSecurityScopedResource()
                    defer { filePath.stopAccessingSecurityScopedResource() }
                    
                    let data = try Data(contentsOf: filePath)
                    async let thumnail = await filePath.thumbnail()
                    let fileName = filePath.deletingPathExtension().lastPathComponent
                    let fileExtension = filePath.pathExtension
                    let path = filePath.path
                    let resolution = filePath.resolution()
                    let duration =  filePath.getDuration()
                    let size = FileManager.default.sizeOfFile(atPath: path) ?? 0
                    let containerName = UUID().uuidString
                    let pathArray = folderPathArray.compactMap({$0.containerName})
                    
                    let vaultFile = await VaultFile(type: filePath.fileType,
                                                    fileName: fileName,
                                                    containerName: containerName,
                                                    files: nil,
                                                    thumbnail: thumnail,
                                                    fileExtension: fileExtension,
                                                    size:size,
                                                    resolution: resolution,
                                                    duration: duration,
                                                    pathArray: pathArray)
                    return (data,vaultFile)
                }
            }
            for try await image in group {
                vaultFileArray += [image]
            }
        })
        
        totalSizeArray = vaultFileArray.compactMap{Double($0.1.size)}
        
        let size = totalSizeArray.reduce(0.0, +)
        
        return (vaultFileArray,size)
    }
    
}

//  VaultManager extension contains the methods used to restore files

extension VaultManager {
    
    func load(fileURL: URL) -> Data? {
        debugLog("\(fileURL)", space: .files)
        
        guard let encryptedData = fileManager.contents(atPath: fileURL) else {
            return nil
        }
        return cryptoManager.decrypt(encryptedData)
    }
    
    func recoverFiles() async {
        let filesToRestore = self.getFilesToRestore()
        await self.recoverFiles(filesToRestore: filesToRestore)
    }
    
    func getFilesToRestore() -> [String] {
        var vaultFileResult : [VaultFile] = []
        self.root.getAllFiles(vaultFileResult: &vaultFileResult)
        let rootContainerName = vaultFileResult.compactMap{$0.containerName }
        
        // return all the content of directory
        let containerURLContent =  fileManager.contentsOfDirectory(atPath: containerURL)
        let allContainerName = containerURLContent.compactMap{$0.lastPathComponent }

        let rootContainerNameSet:Set<String> = Set(rootContainerName)
        var allContainerNameSet:Set<String> = Set(allContainerName)
        
        allContainerNameSet.subtract(rootContainerNameSet)
        
        return Array(allContainerNameSet)
        
        
    }
    
    func saveRetoredFilesToTempFiles(fileToRestore:String) -> URL? {
        
        let fileURL = containerURL(for: fileToRestore)
        
        if fileToRestore != self.rootFileName {
            
            guard let fileData = load(fileURL: fileURL) , var fileExtension = fileData.fileExtension(vaultManager: self) else { return nil}
            
            if fileExtension == FileType.zip.rawValue {
                guard let fileTmpPath = saveDataToTempFile(data: fileData, pathExtension: fileExtension) else { return nil}
                guard let officeExtension =  fileTmpPath.getOfficeExtension() else { return nil }
                fileExtension = officeExtension
            }
            let fileName = fileExtension.getRecoveredFileName()
            return saveDataToTempFile(data: fileData, fileName: fileName, pathExtension: fileExtension)
        }
        
        return nil
    }
    
    func recoverFiles(filesToRestore: [String]) async {
        
        do {
            for fileToRestore in filesToRestore {
                
                guard let fileDetail = try await self.getFilesInfos(fileToRestore: fileToRestore) else {continue}
                
                autoreleasepool {
                    
                    self.importFileAndEncrypt(data: fileDetail.data, vaultFile: fileDetail.file, parentFolder: self.root, type: .image, folderPathArray: [])
                    
                    self.fileManager.removeItem(at: fileDetail.fileUrl)
                }
            }
        }
        catch {
            debugLog("Failed to get files infos")
        }
    }
    
    func getFilesInfos(fileToRestore: String) async throws -> FileDetails?  {
        
        guard  let filePath =  self.saveRetoredFilesToTempFiles(fileToRestore: fileToRestore) else { return nil}
        
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
        let pathArray = [""]
        let vaultFile = await VaultFile(type: filePath.fileType,
                                        fileName: fileName,
                                        containerName: fileToRestore,
                                        files: nil,
                                        thumbnail: thumnail,
                                        fileExtension: pathExtension,
                                        size:size,
                                        resolution: resolution,
                                        duration: duration,
                                        pathArray: pathArray)
        
        return (FileDetails(file: vaultFile, data: data, fileUrl: filePath))
    }
}
