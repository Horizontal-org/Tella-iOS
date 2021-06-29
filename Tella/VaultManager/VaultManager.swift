//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import SwiftUI

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

        root = VaultFile.rootFile(containerName: rootFileName)
        if let root = load(name: rootFileName) {
            self.root = root
        } else {
            save(file: root)
        }
    }

    func importFile(image: UIImage, to parentFolder: VaultFile?, type: FileType) {
        guard let data = image.pngData() else {
            return
        }
        let fileName = "\(type)_new"
        if let newFile = save(data, type: type, name: fileName, parent: parentFolder) {
            if type == .image {
                newFile.thumbnail = image.getThumbnail()?.pngData()
            }
            recentFiles.append(newFile)
            save(file: root)
        }
    }
    
    func importFile(files: [URL], to parentFolder: VaultFile?, type: FileType) {
        for filePath in files {
            debugLog("\(filePath)", space: .crypto)
            let containerName = UUID().uuidString
            let fileName = filePath.lastPathComponent
            do {
                //TODO: add encryption on copying
                let newFilePath = containerURL(for: containerName)
                if filePath.startAccessingSecurityScopedResource() {
                    defer { filePath.stopAccessingSecurityScopedResource() }
                    try FileManager.default.copyItem(at: filePath, to: newFilePath)
                }
            } catch let error {
                debugLog(error, space: .crypto)
                continue
            }
            let newFile = VaultFile(type: .document, fileName: fileName, containerName: containerName, files: nil)
            (parentFolder ?? root).add(file: newFile)
            recentFiles.append(newFile)
        }
        save(file: root)
    }
    
    func load(name: String) -> VaultFile? {
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
        let fileURL = containerURL(for: vaultFile.containerName)
        guard let encryptedData = fileManager.contents(atPath: fileURL) else {
            return nil
        }
        return cryptoManager.decrypt(encryptedData)
    }

    func save(file vaultFile: VaultFile) {
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
        let containerName = UUID().uuidString
        let fileURL = containerURL(for: containerName)
        let vaultFile = VaultFile(type: type, fileName: name, containerName: containerName, files: nil)
        parent?.add(file: vaultFile)
        if let encrypted = cryptoManager.encrypt(data) {
            _ = fileManager.createFile(atPath: fileURL, contents: encrypted)
        } else {
            debugLog("encryption failed \(String(describing: name))", level: .debug, space: .crypto)
        }
        return vaultFile
    }

    func save<T: Datable>(_ object: T, type: FileType, name: String, parent: VaultFile?) -> VaultFile? {
        guard let data = object.data else {
            return nil
        }
        return save(data, type: type, name: name, parent: parent)
    }
    
    func removeAllFiles() {
        do {
            let files = fileManager.contentsOfDirectory(atPath: containerURL)
            for aFile in files {
                if let fileURL = URL(string: aFile) {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch let error{
            debugLog(error)
        }
    }
    
    func delete(file: VaultFile, parent: VaultFile?) {
        parent?.files = parent?.files.filter({ $0.containerName != file.containerName }) ?? []
        
        let fileURL = containerURL(for: file.containerName)
        for aFile in file.files {
            delete(file: aFile, parent: parent)
        }
        fileManager.removeItem(at: fileURL)
    }

    private func containerURL(for containerName: String) -> URL {
        return containerURL.appendingPathComponent(containerName)
    }
    
    private var containerURL: URL {
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask)[0].appendingPathComponent(containerPath)
    }
    
}
