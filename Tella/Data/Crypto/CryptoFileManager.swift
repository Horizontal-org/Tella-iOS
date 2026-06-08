//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

protocol CryptoFileManagerProtocol {
    func recoverKeyData(_ type: KeyFileEnum) -> Data?
    func initKeyFolder(_ keyID: String) throws
    func saveKeyData(_ data: Data, _ type: KeyFileEnum, _ keyID: String) -> Bool
    func deleteKeysRootFolder()
    func keyFileExists(_ type: KeyFileEnum) -> Bool
}

enum KeyFileEnum: String {
    case publicKey = "pub-key.txt"
    case privateKey = "priv-key.txt"
}

class CryptoFileManager: CryptoFileManagerProtocol {
    
    @UserDefaultsProperty(key: VaultUserDefaultsKey.keyID)
    private var keyID: String?
    private static let rootDir = "\(NSHomeDirectory())/Documents"
    private static let baseKeyFolderPath = "\(rootDir)/keys"
    private static let encryptedFolderPath = "\(rootDir)/files"
    private static let fileNameLength = 8

    private let fileManager = FileManager.default
    
    func recoverKeyData(_ type: KeyFileEnum) -> Data? {
        guard let keyID = keyID else { return nil }
        let path = keyFilePath(type, keyID)
        return fileManager.contents(atPath: path)
    }
    
    func initKeyFolder(_ keyID: String) throws {
        let path = keyFolderPath(keyID)
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
    }
    
    func saveKeyData(_ data: Data, _ type: KeyFileEnum, _ keyID: String) -> Bool {
        let path = keyFilePath(type, keyID)
        return fileManager.createFile(atPath: path, contents: data)
    }
    
    func deleteKeysRootFolder() {
        guard fileManager.fileExists(atPath: Self.baseKeyFolderPath) else {
            return
        }

        do {
            try fileManager.removeItem(atPath: Self.baseKeyFolderPath)
        } catch {
            debugLog("Error deleting keys folder: \(error.localizedDescription)")
        }
    }
    
    func keyFileExists(_ type: KeyFileEnum) -> Bool {
        guard let keyID = keyID else { return false }
        let path = keyFilePath(type, keyID)
        return fileManager.fileExists(atPath: path)
    }
    
    private func keyFolderPath(_ keyID: String) -> String {
        "\(Self.baseKeyFolderPath)/\(keyID)"
    }

    private func keyFilePath(_ type: KeyFileEnum, _ keyID: String) -> String {
        let folderPath = keyFolderPath(keyID)
        return "\(folderPath)/\(type.rawValue)"
    }

}
