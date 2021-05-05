//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

enum FileType: String, Codable {
    case video
    case audio
    case document
    case image
    case folder
    case rootFolder
}

class VaultFile: Codable {
    
    let type: FileType
    let fileName: String?
    let containerName: String
    var files: [VaultFile]?
    
    init(type: FileType, fileName: String?, containerName: String, files: [VaultFile]?) {
        self.type = type
        self.fileName = fileName
        self.containerName = containerName
        self.files = files
    }
}

extension VaultFile: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "\(type): \(String(describing: fileName)), \(containerName), \(files?.count ?? 0)"
    }
    
}

extension VaultFile: Equatable {
    
    static func == (lhs: VaultFile, rhs: VaultFile) -> Bool {
        lhs.fileName == rhs.fileName &&
        lhs.containerName == rhs.containerName
    }
    
}

protocol FileManagerInterface: class {
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
    
}

protocol VaultManagerInterface: class {
    
    var containerPath: String { get }

    func load(name: String) -> VaultFile?
    func load(file: VaultFile) -> Data?
    func save(_ data: Data, type: FileType, name: String?, parent: VaultFile?) -> VaultFile?
    func save<T: Datable>(_ object: T, type: FileType, name: String?, parent: VaultFile?) -> VaultFile?

    func delete(file: VaultFile, parent: VaultFile?)
    func removeAllFiles()

}   

class VaultManager: VaultManagerInterface {

    static let shared = VaultManager(cryptoManager: DummyCryptoManager(), fileManager: DefaultFileManager(), rootFileName: "rootFile", containerPath: "")

    let containerPath: String
    private let rootFileName: String
    private var root: VaultFile?
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let cryptoManager: CryptoManagerInterface
    private let fileManager: FileManagerInterface

    init(cryptoManager: CryptoManagerInterface, fileManager: FileManagerInterface, rootFileName: String, containerPath: String) {
        self.cryptoManager = cryptoManager
        self.fileManager = fileManager
        self.rootFileName = rootFileName
        self.containerPath = containerPath
        root = load(name: rootFileName)
    }

    func load(name: String) -> VaultFile? {
        let fileURL = path(for: containerPath)
        guard let encryptedData = FileManager.default.contents(atPath: fileURL.absoluteString) else {
            return nil
        }
        var file: VaultFile?
        do {
            if let decrypted = cryptoManager.decrypt(encryptedData) {
                file = try decoder.decode(VaultFile.self, from: decrypted)
            } else {
                debugLog("file load failed \(name)")
            }
        } catch let error {
            debugLog(error)
        }
        return file
    }

    func load(file vaultFile: VaultFile) -> Data? {
        let fileURL = path(for: vaultFile.containerName)
        guard let encryptedData = fileManager.contents(atPath: fileURL) else {
            return nil
        }
        return cryptoManager.decrypt(encryptedData)
    }

    func save(file vaultFile: VaultFile) {
        let fileURL = path(for: rootFileName).appendingPathComponent(vaultFile.containerName)
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
    }
    
    func save(_ data: Data, type: FileType, name: String?, parent: VaultFile?) -> VaultFile? {
        let containerName = UUID().uuidString
        let fileURL = path(for: containerName)
        let vaultFile = VaultFile(type: type, fileName: name, containerName: containerName, files: nil)
        parent?.files?.append(vaultFile)
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
        let fileURL = path(for: file.containerName)
        //TODO: delete file at path
//        parent?.files =
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error {
            debugLog(error)
        }
    }

    private func path(for containerName: String) -> URL {
        return containerURL.appendingPathComponent(containerName)
    }
    
    private var containerURL: URL {
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask)[0].appendingPathComponent(containerPath)
    }

}
