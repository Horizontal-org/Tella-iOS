//
//  CryptoManager.swift
//  Tella
//
//  Created by Oliphant, Samuel on 3/9/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import Foundation

struct CryptoManager {
    
    private static let metaPrivateKeyTag = "org.hzontal.tella.ios"
    private static let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM
    private static let metaPrivateKeyQuery: [String: Any] = [kSecClass as String: kSecClassKey,
                                                         kSecAttrApplicationTag as String: metaPrivateKeyTag,
                                                         kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                                                         kSecReturnRef as String: true,
                                                         kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave]
    
    private static func getOptions(_ type: KeyEnum) -> [String: Any] {
        switch (type) {
        case .META_PRIVATE:
            return [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits as String : 256,
                kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave]
        case .META_PUBLIC, .PUBLIC:
            return [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits as String : 256]
        case .PRIVATE:
            return [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits as String : 256]
        }
    }
    
    static func metaPrivateKeyExists() -> Bool {
        return recoverMetaPrivateKey() != nil
    }
    
    static func recoverMetaPrivateKey() -> SecKey? {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(metaPrivateKeyQuery as CFDictionary, &item)
        guard status == errSecSuccess else {
            print("Error: \(SecCopyErrorMessageString(status, nil) ?? "" as CFString)")
            return nil
        }
        let key = item as! SecKey
        return key
    }
    
    static func recoverKey(_ type: KeyEnum) -> SecKey? {
        guard let keyFileType = type.toKeyFileEnum() else {
            return recoverMetaPrivateKey()
        }
        guard var data = TellaFileManager.recoverKeyData(keyFileType) else {
            print("key not found")
            return nil
        }
        if type == .PRIVATE {
            guard let metaPrivateKey = recoverKey(.META_PRIVATE) else {
                print("meta private key not recovered")
                return nil
            }
            guard let decryptedData = decrypt(data, metaPrivateKey) else {
                print("data not decrypted")
                return nil
            }
            data = decryptedData
        }
        let options: [String: Any] = getOptions(type)
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(data as CFData, options as CFDictionary, &error) else {
            print("Error: \(error?.takeRetainedValue().localizedDescription ?? "")")
            return nil
        }
        return key
    }

    static func deleteMetaKeypair() throws {
        let status = SecItemDelete(metaPrivateKeyQuery as CFDictionary)
        if status != errSecSuccess {
            throw RuntimeError("Failed to delete meta private key in enclave")
        }
        TellaFileManager.deleteKeyFile(.META_PUBLIC)
    }
    
    static func deleteKeypair() {
        TellaFileManager.deleteKeyFile(.PUBLIC)
        TellaFileManager.deleteKeyFile(.PRIVATE)
    }
    
    static func saveMetaPublicKey(_ privateKey: SecKey) {
        print("Saving meta public")
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            print("Failed to generate meta public key")
            return
        }
        var error2: Unmanaged<CFError>?
        guard let publicData = SecKeyCopyExternalRepresentation(publicKey, &error2) as Data? else {
            print("Error: \(error2?.takeRetainedValue().localizedDescription ?? "")")
            return
        }
        TellaFileManager.saveKeyData(publicData, .META_PUBLIC)
        print("Done saving meta public")
    }
    
    static func saveKeypair(_ privateKey: SecKey) {
        var error: Unmanaged<CFError>?
        guard let privateData = SecKeyCopyExternalRepresentation(privateKey, &error) as Data? else {
            print("Error: \(error?.takeRetainedValue().localizedDescription ?? "")")
            return
        }
        guard let metaPublicKey = recoverKey(.META_PUBLIC) else {
            print("Error: Could not recover meta public key")
            return
        }
        guard let privateEncryptedData = encrypt(privateData, metaPublicKey) else {
            print("Error: Could not encrypt private key")
            return
        }
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            print("Failed to generate public key")
            return
        }
        var error2: Unmanaged<CFError>?
        guard let publicData = SecKeyCopyExternalRepresentation(publicKey, &error2) as Data? else {
            print("Error: \(error2?.takeRetainedValue().localizedDescription ?? "")")
            return
        }
        TellaFileManager.saveKeyData(privateEncryptedData, .PRIVATE)
        TellaFileManager.saveKeyData(publicData, .PUBLIC)
    }
    
    private static func createMetaPrivateKey(_ type: PasswordTypeEnum) throws -> SecKey {
        var flags = SecAccessControlCreateFlags.privateKeyUsage
        flags.formUnion(type.toFlag())
        let access = SecAccessControlCreateWithFlags(
                kCFAllocatorDefault,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                flags,
                nil)!
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: metaPrivateKeyTag,
                kSecAttrAccessControl as String: access
            ]
        ]
        var error: Unmanaged<CFError>?
        guard let metaPrivateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            let msg = "Error: \(error?.takeRetainedValue().localizedDescription ?? "")"
            throw RuntimeError(msg)
        }
        return metaPrivateKey
    }
    
    private static func createPrivateKey() -> SecKey? {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256
        ]
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("Error: \(error?.takeRetainedValue().localizedDescription ?? "")")
            return nil
        }
        return privateKey
    }
    
    static func keysInitialized() -> Bool {
        return metaPrivateKeyExists() && TellaFileManager.keyFileExists(.PRIVATE)
    }
    
    static func initKeys(_ type: PasswordTypeEnum) throws {
        print("Creating all-new keys")
        guard let privateKey = createPrivateKey() else {
            print("Creating private key failed")
            return
        }
        try keyHelper(privateKey, type)
    }
    
    static func updateKeys(_ privateKey: SecKey, _ type: PasswordTypeEnum) throws {
        try deleteMetaKeypair()
        try keyHelper(privateKey, type)
    }
    
    private static func keyHelper(_ privateKey: SecKey, _ type: PasswordTypeEnum) throws {
        let metaPrivateKey = try createMetaPrivateKey(type)
        saveMetaPublicKey(metaPrivateKey)
        saveKeypair(privateKey)
    }
    
    static func encryptUserData(_ data: Data) -> Data? {
        guard let publicKey = recoverKey(.PUBLIC) else {
            print("Failed to recover public key")
            return nil
        }
        return encrypt(data, publicKey)
    }
    
    private static func encrypt(_ data: Data, _ publicKey: SecKey) -> Data? {
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            print("Algorithm is not supported")
            return nil
        }
        var error: Unmanaged<CFError>?
        guard let cipherText = SecKeyCreateEncryptedData(publicKey, algorithm, data as CFData, &error) as Data? else {
            print("Error: Failed to produce cipher text. \(error!.takeRetainedValue().localizedDescription)")
            return nil
        }
        return cipherText
    }
    
    static func decrypt(_ data: Data, _ privateKey: SecKey) -> Data? {
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
            print("Algorithm is not supported")
            return nil
        }
        var error: Unmanaged<CFError>?
        guard let clearText = SecKeyCreateDecryptedData(privateKey, algorithm, data as CFData, &error) as Data? else {
            print("Decryption failed: \(error!.takeRetainedValue().localizedDescription)")
            return nil
        }
        return clearText
    }
}
