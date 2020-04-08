//
//  CryptoManager.swift
//  Tella
//
//  Created by Oliphant, Samuel on 3/9/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import Foundation

struct CryptoManager {
    
    private static let privateKeyTag = "org.hzontal.tella.ios"
    static let publicKeyPath = "\(TellaFileManager.rootDir)/keys/pub-key.txt"
    
    private static let privateKeyQuery: [String: Any] = [kSecClass as String: kSecClassKey,
                                                         kSecAttrApplicationTag as String: privateKeyTag,
                                                         kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                                                         kSecReturnRef as String: true,
                                                         kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave]
    
    static func recoverPublicKey() -> SecKey? {
        let options: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                                      kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                                      kSecAttrKeySizeInBits as String : 256]
        var error: Unmanaged<CFError>?
        guard let data = TellaFileManager.recoverData(publicKeyPath) else {
            print("key not found")
            return nil
        }
        guard let key = SecKeyCreateWithData(data as CFData, options as CFDictionary, &error) else {
            print("Error: \(error?.takeRetainedValue().localizedDescription ?? "")")
            return nil
        }
        return key
    }
    
    static func recoverPrivateKey() -> SecKey? {
        print("recovering")
        var item: CFTypeRef?
        let status = SecItemCopyMatching(privateKeyQuery as CFDictionary, &item)
        guard status == errSecSuccess else {
            print("Error: \(SecCopyErrorMessageString(status, nil) ?? "" as CFString)")
            return nil
        }
        print("status passed")
        let key = item as! SecKey
        print("got key")
        return key
    }
    
    static func privateKeyExists() -> Bool {
        return recoverPrivateKey() != nil
    }
    
    static func publicKeyExists() -> Bool {
        return recoverPublicKey() != nil
    }
    
    static func deletePrivateKey() {
        if privateKeyExists() {
            let status = SecItemDelete(privateKeyQuery as CFDictionary)
            guard status == errSecSuccess else {
                print("Failed to delete private key")
                return
            }
        } else {
            print("Private key did not exist")
        }
    }
    
    static func savePublicKey(_ privateKey: SecKey) {
        let publicKey = SecKeyCopyPublicKey(privateKey)!
        var error2: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(publicKey, &error2) as Data? else {
            print("Error: \(error2?.takeRetainedValue().localizedDescription ?? "")")
            return
        }
        TellaFileManager.writePublicKey(data)
    }
    
    static func initKeys() {
        if !privateKeyExists() {
            let flags = SecAccessControlCreateFlags(rawValue:
                            SecAccessControlCreateFlags.privateKeyUsage.rawValue |
                            SecAccessControlCreateFlags.applicationPassword.rawValue)
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
                    kSecAttrApplicationTag as String: privateKeyTag,
                    kSecAttrAccessControl as String: access
                ]
            ]
            var error: Unmanaged<CFError>?
            guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
                print("Error: \(error?.takeRetainedValue().localizedDescription ?? "")")
                return
            }
            savePublicKey(privateKey)
        } else {
            if !publicKeyExists() {
                guard let privateKey = recoverPrivateKey() else {
                    print("Failed to recover private key even though it exists")
                    return
                }
                savePublicKey(privateKey)
            }
        }
    }
    
    static func encrypt(_ data: Data) -> Data? {
        guard let publicKey = recoverPublicKey() else {
            print("Failed to recover public key")
            return nil
        }
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM
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
    
    static func decrypt(_ data: Data, _ privKey: SecKey? = nil) -> Data? {
        let privateKey: SecKey
        if let unwrapped = privKey {
            privateKey = unwrapped
        } else {
            if let unwrapped = recoverPrivateKey() {
                privateKey = unwrapped
            } else {
                print("Failed to recover private key")
                return nil
            }
        }
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM
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
