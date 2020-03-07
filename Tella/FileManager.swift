//
//  FileManager.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/25/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//
import Foundation
import UIKit

struct TellaFileManager {
    
    private static let instance = FileManager.default
    private static let rootDir = "\(NSHomeDirectory())/Documents"
    private static let keyFolderPath = "\(rootDir)/keys"
    private static let encryptedFolderPath = "\(rootDir)/files"
    private static let publicKeyPath = "\(encryptedFolderPath)/pub-key.txt"
    private static let fileNameLength = 12
    
    static func initDirectories() {
        initDirectory(keyFolderPath)
        initDirectory(encryptedFolderPath)
    }
    
    static func initKeys() {
        let flags = SecAccessControlCreateFlags(rawValue: SecAccessControlCreateFlags.biometryAny.rawValue | SecAccessControlCreateFlags.privateKeyUsage.rawValue | SecAccessControlCreateFlags.applicationPassword.rawValue)
        let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, flags, nil)!
        let attributes: [String: Any] = [
          kSecAttrKeyType as String:            kSecAttrKeyTypeECSECPrimeRandom,
          kSecAttrKeySizeInBits as String:      256,
          kSecAttrTokenID as String:            kSecAttrTokenIDSecureEnclave,
          kSecPrivateKeyAttrs as String: [
            kSecAttrIsPermanent as String:      true,
            kSecAttrApplicationTag as String:   "testing-tag-1",
            kSecAttrAccessControl as String:    access
          ]
        ]
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("Error: \(error?.takeRetainedValue().localizedDescription ?? "")")
            return
        }
        let publicKey = SecKeyCopyPublicKey(privateKey)
        
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
    
    static func savePublicKey(_ key: String) {
        instance.createFile(atPath: publicKeyPath, contents: key.data(using: String.Encoding.utf8)!)
    }
    
    static func saveEncryptedFile() {
        //TODO
    }
    
    static func saveTextFile(_ text: String) {
        saveFile(text.data(using: String.Encoding.utf8)!, .TEXT)
    }
    
    static func saveImage(_ image: UIImage) {
        if let fixed = image.fixedOrientation() {
            saveFile(fixed.pngData()!, .IMAGE)
        }
    }
    
    private static func saveFile(_ data: Data, _ type: FileTypeEnum) {
        var foundNewName = false
        var newName = getRandomFilename(type)
        while !foundNewName {
            if !instance.fileExists(atPath: "\(encryptedFolderPath)/\(newName)") {
                foundNewName = true
            } else {
                newName = getRandomFilename(type)
            }
        }
        instance.createFile(atPath: "\(encryptedFolderPath)/\(newName)", contents: data)
    }
    
    static func copyExternalFile(_ url: URL) {
        do {
            try instance.copyItem(atPath: url.path, toPath: "\(encryptedFolderPath)/\(getRandomFilename(urlToFileTypeEnum(url)))")
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    static func recoverImageFile(_ atPath: String) -> UIImage? {
        let data = instance.contents(atPath: atPath)
        if let unwrapped = data {
            return UIImage(data: unwrapped)
        }
        return nil
    }
    
    static func recoverTextFile(_ atPath: String) -> String? {
        let data = instance.contents(atPath: atPath)
        if let unwrapped = data {
            return String(data: unwrapped, encoding: String.Encoding.utf8)
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
    
    private static func getRandomFilename(_ type: FileTypeEnum) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<TellaFileManager.fileNameLength).map{ _ in letters.randomElement()! }) + "." + type.rawValue
    }
    
    static func deleteEncryptedFile(name: String) {
        do {
            try instance.removeItem(atPath: "\(encryptedFolderPath)/\(name)")
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
}
