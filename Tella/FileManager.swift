//
//  FileManager.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/25/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import UIKit

struct TellaFileManager {
    
    private static let instance = FileManager.default
    static let rootDir = "\(NSHomeDirectory())/Documents"
    private static let keyFolderPath = "\(rootDir)/keys"
    private static let encryptedFolderPath = "\(rootDir)/files"
    private static let fileNameLength = 12
    
    static func initDirectories() {
        initDirectory(keyFolderPath)
        initDirectory(encryptedFolderPath)
    }
    
    static func clearAllFiles() {
        do {
            try instance.removeItem(atPath: keyFolderPath)
            try instance.removeItem(atPath: encryptedFolderPath)
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private static func initDirectory(_ atPath: String) {
        if !instance.fileExists(atPath: atPath) {
            do {
                try instance.createDirectory(atPath: atPath, withIntermediateDirectories: true)
            } catch let error {
                print("Error: \(error.localizedDescription)")
                // Quits app because initialization failed
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                return
            }
        }
    }
    
    static func saveTextFile(_ text: String) {
        saveFile(text.data(using: String.Encoding.utf8)!, FileTypeEnum.TEXT.rawValue)
    }
    
    static func saveImage(_ image: UIImage) {
        if let fixed = image.fixedOrientation() {
            if let pngData = fixed.pngData() {
                saveFile(pngData, FileTypeEnum.IMAGE.rawValue)
            }
        }
    }
    
    private static func saveFile(_ data: Data, _ type: String) {
        var foundNewName = false
        var newName = getRandomFilename(type)
        while !foundNewName {
            if !instance.fileExists(atPath: "\(encryptedFolderPath)/\(newName)") {
                foundNewName = true
            } else {
                newName = getRandomFilename(type)
            }
        }
        if let encrypted = CryptoManager.encrypt(data) {
            instance.createFile(atPath: "\(encryptedFolderPath)/\(newName)", contents: encrypted)
        } else {
            print("encryption failed")
        }
    }
    
    static func copyExternalFile(_ url: URL) {
        do {
            try instance.copyItem(atPath: url.path, toPath: "\(encryptedFolderPath)/\(getRandomFilename(url.pathExtension))")
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    static func recoverImageFile(_ atPath: String) -> UIImage? {
        let data = recoverAndDecrypt(atPath)
        if let unwrapped = data {
            return UIImage(data: unwrapped)
        }
        return nil
    }
    
    static func tempSaveText() {
        saveTextFile("hi")
    }
    
    static func recoverTextFile(_ atPath: String) -> String? {
        let data = recoverAndDecrypt(atPath)
        if let unwrapped = data {
            return String(data: unwrapped, encoding: String.Encoding.utf8)
        }
        return nil
    }
    
    static func recoverAndDecrypt(_ atPath: String) -> Data? {
        if let data = recoverData(atPath) {
            if let decrypted = CryptoManager.decrypt(data) {
                return decrypted
            }
        }
        return nil
    }
    
    static func recoverData(_ atPath: String) -> Data? {
        return instance.contents(atPath: atPath)
    }
    
    static func getEncryptedFileNames() -> [String] {
        do {
            let arrDirContent = try instance.contentsOfDirectory(atPath: encryptedFolderPath)
            return arrDirContent
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return []
        }
    }
    
    static func fileNameToPath(name: String) -> String {
        return "\(encryptedFolderPath)/\(name)"
    }
    
    private static func getRandomFilename(_ type: String) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<TellaFileManager.fileNameLength).map{ _ in letters.randomElement()! }) + "." + type
    }
    
    static func deleteEncryptedFile(name: String) {
        do {
            try instance.removeItem(atPath: "\(encryptedFolderPath)/\(name)")
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    static func writePublicKey(_ data: Data) {
        deletePublicKey()
        instance.createFile(atPath: CryptoManager.publicKeyPath, contents: data)
    }
    
    static func deletePublicKey() {
        if CryptoManager.publicKeyExists() {
            do {
                try instance.removeItem(atPath: CryptoManager.publicKeyPath)
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        } else {
            print("Public key did not exist")
        }
    }
}
