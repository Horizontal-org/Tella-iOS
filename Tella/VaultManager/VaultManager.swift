//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit

protocol VaultManagerInterface {
    
    var containerPath: String { get }

    func load(name: String) -> VaultFile?
    func load(file: VaultFile) -> Data?
    func save(_ data: Data, type: FileType, name: String, parent: VaultFile?) -> VaultFile?
    func save<T: Datable>(_ object: T, type: FileType, name: String, parent: VaultFile?) -> VaultFile?

    func delete(file: VaultFile, parent: VaultFile?)
    func removeAllFiles()

}   

class VaultManager: VaultManagerInterface, ObservableObject {

    let containerPath: String
    private let rootFileName: String
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let cryptoManager: CryptoManagerInterface
    private let fileManager: FileManagerInterface

    @Published var root: VaultFile
    @Published var recentFiles: [VaultFile] = []

    init(cryptoManager: CryptoManagerInterface, fileManager: FileManagerInterface, rootFileName: String, containerPath: String) {
        self.cryptoManager = cryptoManager
        self.fileManager = fileManager
        self.rootFileName = rootFileName
        self.containerPath = containerPath

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

    func importFile(image: UIImage, to parentFolder: VaultFile?, type: FileType) {
        debugLog("\(image)", space: .files)
        guard let data = image.pngData() else {
            return
        }
        let fileName = "\(type)_new"
        if let newFile = save(data, type: type, name: fileName, parent: parentFolder) {
            if type == .image {
                newFile.thumbnail = image.getThumbnail()?.pngData()
            }
            addRecentFile(file: newFile)
            save(file: root)
        }
    }
    
    func importFile(files: [URL], to parentFolder: VaultFile?, type: FileType) {
        for filePath in files {
            debugLog("\(filePath)", space: .files)

            let containerName = UUID().uuidString
            let fileName = filePath.lastPathComponent
            let newFilePath = containerURL(for: containerName)
            do {
                //TODO: add encryption on copying
                if filePath.startAccessingSecurityScopedResource() {
                    defer { filePath.stopAccessingSecurityScopedResource() }
                    try fileManager.copyItem(at: filePath, to: newFilePath)
                }
            } catch let error {
                debugLog(error, space: .crypto)
                continue
            }
            let fileType = filePath.fileType
            let thumbnail = filePath.thumbnail?.pngData()
            let newFile = VaultFile(type: fileType, fileName: fileName, containerName: containerName, thumbnail: thumbnail)
            (parentFolder ?? root).add(file: newFile)
            addRecentFile(file: newFile)
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
    
    func save(_ data: Data, type: FileType, name: String, parent: VaultFile?) -> VaultFile? {
        debugLog("\(data.count); \(type); \(name); \nparent:\(String(describing: parent))", space: .files)
        
        let containerName = UUID().uuidString
        let fileURL = containerURL(for: containerName)
        guard let encrypted = cryptoManager.encrypt(data),
                fileManager.createFile(atPath: fileURL, contents: encrypted) else {
            debugLog("encryption failed \(String(describing: name))", level: .debug, space: .crypto)
            return nil
        }
        
        let vaultFile = VaultFile(type: type, fileName: name, containerName: containerName, files: nil)
        parent?.add(file: vaultFile)
        return vaultFile
    }

    func save<T: Datable>(_ object: T, type: FileType, name: String, parent: VaultFile?) -> VaultFile? {
        guard let data = object.data else {
            return nil
        }
        return save(data, type: type, name: name, parent: parent)
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
    
}
