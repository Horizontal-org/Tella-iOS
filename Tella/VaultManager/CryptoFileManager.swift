//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

protocol CryptoFileManagerProtocol {
    func recoverKeyData(_ type: KeyFileEnum) -> Data?
    func initKeyFolder(_ keyID: String) throws
    func saveKeyData(_ data: Data, _ type: KeyFileEnum, _ keyID: String) -> Bool
    func deleteKeyFolder(_ keyID: String)
    func keyFileExists(_ type: KeyFileEnum) -> Bool
}

class CryptoFileManager: CryptoFileManagerProtocol {
    
    @UserDefaultsProperty(key: "keyID")
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
    
    func deleteKeyFolder(_ keyID: String) {
        let path = keyFolderPath(keyID)
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch let error {
                debugLog("Error: \(error.localizedDescription)")
            }
        } else {
            debugLog("\(path) did not exist")
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
