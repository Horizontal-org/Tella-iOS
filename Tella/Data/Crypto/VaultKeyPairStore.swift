//
//  VaultKeyPairStore.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Security

protocol VaultKeyPairStoring: AnyObject {
    func writeEncryptedVaultKeypair(
        privateKey: SecKey,
        metaPrivateKey: SecKey
    ) throws
    func verifyKeychainVaultMatches(
        vaultKey: SecKey,
        metaPrivateKey: SecKey
    ) -> Bool
    func rollback(password: String, keyID: String?)
}

final class VaultKeyPairStore: VaultKeyPairStoring {
    
    private let keychainStore: VaultKeychainStoring
    
    init(keychainStore: VaultKeychainStoring) {
        self.keychainStore = keychainStore
    }
    
    func writeEncryptedVaultKeypair(
        privateKey: SecKey,
        metaPrivateKey: SecKey
    ) throws {
        var privateData = try privateKey.externalRepresentationOrThrow(
            "Failed to export vault private key"
        )
        defer {
            privateData.secureWipe()
        }
        
        guard let metaPublicKey = metaPrivateKey.getPublicKey() else {
            throw RuntimeError("Failed to create meta public key")
        }
        
        guard let encryptedPrivateData = metaPublicKey.eciesEncrypt(privateData) else {
            throw RuntimeError("Failed to encrypt vault private key")
        }
        
        guard keychainStore.saveEncryptedPrivateKey(encryptedPrivateData) else {
            throw RuntimeError("Failed to save encrypted private key in Keychain")
        }
    }
    
    func verifyKeychainVaultMatches(
        vaultKey: SecKey,
        metaPrivateKey: SecKey
    ) -> Bool {
        guard let encryptedPrivateData = keychainStore.recoverEncryptedPrivateKey() else {
            return false
        }
        
        guard var decryptedPrivateData = metaPrivateKey.eciesDecrypt(encryptedPrivateData) else {
            return false
        }
        defer {
            decryptedPrivateData.secureWipe()
        }
        
        guard let recoveredPrivateKey = SecKey.makeKey(
            from: decryptedPrivateData,
            options: [
                kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits as String: 256
            ]
        ) else {
            return false
        }
        
        guard var originalPrivateData = vaultKey.getData(),
              var recoveredPrivateData = recoveredPrivateKey.getData() else {
            return false
        }
        defer {
            originalPrivateData.secureWipe()
            recoveredPrivateData.secureWipe()
        }
        
        guard originalPrivateData == recoveredPrivateData else {
            return false
        }
        
        return recoveredPrivateKey.getPublicKey() != nil
    }
    
    func rollback(password: String, keyID: String?) {
        _ = keychainStore.deleteEncryptedPrivateKey()
        if let keyID {
            _ = keychainStore.delete(
                keyID: keyID,
                password: password
            )
        }
    }
}
