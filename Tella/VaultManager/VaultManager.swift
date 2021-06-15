//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

enum FileType: String, Codable {
    case video
    case audio
    case document
    case image
    case folder
    case rootFolder
}

class VaultFile: Codable, ObservableObject, RecentFileProtocol {
    
    let type: FileType
    let fileName: String?
    let containerName: String
    var files: [VaultFile]
    var thumbnail: Data?
    var created: Date
    
    var thumbnailImage: UIImage {
        if let thumbnail = thumbnail, let image = UIImage(data: thumbnail) {
            return image
        }
        switch type {
        case .audio:
           return #imageLiteral(resourceName: "filetype.audio")
        case .document:
            return #imageLiteral(resourceName: "filetype.document")
        case .folder:
            return #imageLiteral(resourceName: "filetype.folder")
        case .video:
            return #imageLiteral(resourceName: "filetype.video")
        case .image:
            return #imageLiteral(resourceName: "filetype.document")
        default:
            return #imageLiteral(resourceName: "filetype.document")
        }
    }
    
    init(type: FileType, fileName: String?, containerName: String, files: [VaultFile]?) {
        self.type = type
        self.fileName = fileName
        self.containerName = containerName
        self.files = files ?? []
        self.created = Date()
    }
    
    static func rootFile(containerName: String) -> VaultFile {
        return VaultFile(type: .folder, fileName: "", containerName: containerName, files: [])
    }
    
}

extension VaultFile: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "\(type): \(String(describing: fileName)), \(containerName), \(files.count)"
    }
    
}

extension VaultFile: Equatable {
    
    static func == (lhs: VaultFile, rhs: VaultFile) -> Bool {
        lhs.fileName == rhs.fileName &&
        lhs.containerName == rhs.containerName
    }
    
}

protocol FileManagerInterface {
    func copyItem(at srcURL: URL, to dstURL: URL) throws
    func contents(atPath path: URL) -> Data?
    func contentsOfDirectory(atPath path: URL) -> [String]

    @discardableResult
    func createFile(atPath path: URL, contents data: Data?) -> Bool
    func removeItem(at path: URL)
}

class DefaultFileManager: FileManagerInterface {
    let fileManager = FileManager.default
    
    func contents(atPath path: URL) -> Data? {
        do {
            return try Data(contentsOf: path)
        } catch let error {
            debugLog(error)
        }
        return nil
    }
    
    func contentsOfDirectory(atPath path: URL) -> [String] {
        do {
            return try fileManager.contentsOfDirectory(atPath: path.absoluteString)
        } catch let error {
            debugLog(error)
        }
        return []
    }
    
    func removeItem(at path: URL) {
        do {
            try fileManager.removeItem(at: path)
        } catch let error {
            debugLog(error)
        }
    }
 
    func createFile(atPath path: URL, contents data: Data?) -> Bool {
        do {
            try data?.write(to: path)
        } catch let error {
            debugLog(error)
            return false
        }
        return true
    }
    
    func copyItem(at srcURL: URL, to dstURL: URL) throws {
        try fileManager.copyItem(at: srcURL, to: dstURL)
    }
    
}

protocol VaultManagerInterface {
    
    var containerPath: String { get }

    func load(name: String) -> VaultFile?
    func load(file: VaultFile) -> Data?
    func save(_ data: Data, type: FileType, name: String?, parent: VaultFile?) -> VaultFile?
    func save<T: Datable>(_ object: T, type: FileType, name: String?, parent: VaultFile?) -> VaultFile?

    func delete(file: VaultFile, parent: VaultFile?)
    func removeAllFiles()

}   

class VaultManager: VaultManagerInterface, ObservableObject {

    static let shared = VaultManager(cryptoManager: DummyCryptoManager(), fileManager: DefaultFileManager(), rootFileName: "rootFile", containerPath: "")

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

    func importFile(files: [URL], to parentFolder: VaultFile?){
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
            (parentFolder ?? root).files.append(newFile)
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
    
    func save(_ data: Data, type: FileType, name: String?, parent: VaultFile?) -> VaultFile? {
        let containerName = UUID().uuidString
        let fileURL = containerURL(for: containerName)
        let vaultFile = VaultFile(type: type, fileName: name, containerName: containerName, files: nil)
        parent?.files.append(vaultFile)
        if let encrypted = cryptoManager.encrypt(data) {
            _ = fileManager.createFile(atPath: fileURL, contents: encrypted)
        } else {
            debugLog("encryption failed \(String(describing: name))", level: .debug, space: .crypto)
        }
        return vaultFile
    }

    func save<T: Datable>(_ object: T, type: FileType, name: String?, parent: VaultFile?) -> VaultFile? {
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
        let fileURL = containerURL(for: file.containerName)
        //TODO: delete file at path
        for aFile in file.files {
            delete(file: aFile, parent: nil)
        }
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error {
            debugLog(error)
        }
    }

    private func containerURL(for containerName: String) -> URL {
        return containerURL.appendingPathComponent(containerName)
    }
    
    private var containerURL: URL {
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask)[0].appendingPathComponent(containerPath)
    }
    
}
