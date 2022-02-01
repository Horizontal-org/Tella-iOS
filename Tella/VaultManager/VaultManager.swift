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
    func save(_ data: Data, vaultFile: VaultFile, parent: VaultFile?) -> Bool?
    func save<T: Datable>(_ object: T, vaultFile: VaultFile, parent: VaultFile? ) -> Bool?
    func createNewFolder(name: String, parent: VaultFile?)
    func rename(file : VaultFile, parent: VaultFile?)
    func delete(file: VaultFile, parent: VaultFile?)
    func removeAllFiles()
    
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
    @Published var recentFiles: [VaultFile] = []
    var progress :  ImportProgress
    var shouldCancelImportAndEncryption = CurrentValueSubject<Bool,Never>(false)
    
    private var cancellable: Set<AnyCancellable> = []
    
    init(cryptoManager: CryptoManagerInterface, fileManager: FileManagerInterface, rootFileName: String, containerPath: String, progress :  ImportProgress) {
        self.cryptoManager = cryptoManager
        self.fileManager = fileManager
        self.rootFileName = rootFileName
        self.containerPath = containerPath
        self.progress = progress
        
        root = VaultFile.rootFile(fileName: "..", containerName: rootFileName)
        if let root = load(name: rootFileName) {
            self.root = root
        } else {
            save(file: root)
        }
        
        do {
            try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            debugLog(error)
        }
    }
    
    func importFile(image: UIImage, to parentFolder: VaultFile?, type: FileType, pathExtension: String) {
        
        self.progress.start(currentFile: 0, totalFiles: 1, totalSize: Double(image.data?.count ?? 0))
        
        debugLog("\(image)", space: .files)
        guard let data = image.fixedOrientation() else {
            return
        }
        
        let width = image.size.width * image.scale
        let height = image.size.height * image.scale
        let resolution = CGSize(width: width, height: height)
        let size = Int64(data.data?.count ?? 0)
        let thumbnail = image.getThumbnail()?.pngData()
        let fileName = "\(type)_new"
        let containerName = UUID().uuidString

        let vaultFile = VaultFile(type: .image,
                                  fileName: fileName,
                                  containerName: containerName,
                                  files: nil,
                                  thumbnail: thumbnail,
                                  fileExtension: "png",
                                  size:size,
                                  resolution: resolution,
                                  duration: nil)

        if let _ = save(data, vaultFile: vaultFile, parent: parentFolder) {
            addRecentFile(file: vaultFile)
            save(file: root)
            self.progress.finish()
        }
    }
    
    func importFile(files: [URL], to parentFolder: VaultFile?, type: FileType) {
        
        let filesInfo = self.getFilesInfo(files: files)
        
        self.progress.start(totalFiles: files.count, totalSize: filesInfo.1)

        let queue = DispatchQueue.global(qos: .background)
        
        var backgroundWorkItem : DispatchWorkItem?
        backgroundWorkItem = DispatchWorkItem {
            for (index, item) in filesInfo.0.enumerated() {
                if (backgroundWorkItem?.isCancelled)! {
                    break
                }
                self.progress.currentFile = index
                self.importFileAndEncrypt(data: item.0, vaultFile: item.1, parentFolder: parentFolder, type: type)
            }
            
            self.save(file: self.root)
            self.progress.finish()
        }
        
        queue.async(execute: backgroundWorkItem!)
        
        self.shouldCancelImportAndEncryption.sink(receiveValue: { value in
            if value {
                backgroundWorkItem?.cancel()
                self.progress.stop()
                self.shouldCancelImportAndEncryption.value = false
            }
            
        }).store(in: &self.cancellable)
    }
    
    private func importFileAndEncrypt(data : Data, vaultFile:VaultFile, parentFolder :VaultFile?, type: FileType) {
        
        if let _ = self.save(data, vaultFile: vaultFile, parent: parentFolder) {
            self.addRecentFile(file: vaultFile)
        }
    }
    
    func createNewFolder(name: String, parent: VaultFile?)  {
        
        let vaultFile = VaultFile(type: .folder, fileName: name, files: nil)
        parent?.add(file: vaultFile)
        addRecentFile(file: vaultFile)
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
        
        let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(vaultFile.fileName)
        
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

    
    func removeAllFiles() {
        debugLog("", space: .files)
        
        for file in root.files {
            delete(file: file, parent: root)
        }
        
        //        let files = fileManager.contentsOfDirectory(atPath: containerURL)
        //        for fileURL in files {
        //            fileManager.removeItem(at: fileURL)
        //        }
        root = VaultFile.rootFile(fileName: "..", containerName: rootFileName)
        save(file: root)
        recentFiles = []
    }
    
    func delete(file: VaultFile, parent: VaultFile?) {
        debugLog("\(file)", space: .files)
        parent?.remove(file: file)
        removeRecentFile(file: file)
        
        for aFile in file.files {
            delete(file: aFile, parent: parent)
        }
        let fileURL = containerURL(for: file.containerName)
        fileManager.removeItem(at: fileURL)
        save(file: root)
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
    
    //MARK: recent file
    private func addRecentFile(file: VaultFile) {
        debugLog("\(file)", space: .files)
        recentFiles.append(file)
    }
    
    private func removeRecentFile(file: VaultFile) {
        recentFiles = recentFiles.filter({ $0.containerName != file.containerName })
    }
    
    private func getFilesInfo(files: [URL]) ->([(Data,VaultFile)], Double) {
        var totalSizeArray : [Double] = []
        var vaultFileArray : [(Data,VaultFile)] = []
        
        files.forEach { filePath in
            do {
                debugLog("\(filePath)", space: .files)

                let _ = filePath.startAccessingSecurityScopedResource()
                defer { filePath.stopAccessingSecurityScopedResource() }
                
                let data = try Data(contentsOf: filePath)
                let fileName = filePath.lastPathComponent
                let fileExtension = filePath.pathExtension
                let path = filePath.path
                
                let resolution = filePath.resolution()
                let duration =  filePath.getDuration()
                let size = FileManager.default.sizeOfFile(atPath: path) ?? 0
                let containerName = UUID().uuidString

                let vaultFile = VaultFile(type: filePath.fileType,
                                          fileName: fileName,
                                          containerName: containerName,
                                          files: nil,
                                          thumbnail: filePath.thumbnail,
                                          fileExtension: fileExtension,
                                          size:size,
                                          resolution: resolution,
                                          duration: duration)
                
                vaultFileArray.append((data,vaultFile))
                totalSizeArray.append(Double(size))
            }
            catch  let error {
                debugLog(error)
            }
        }
        
        let totalSize = totalSizeArray.reduce(0.0, +)
        
        return(vaultFileArray, totalSize)
    }
}
