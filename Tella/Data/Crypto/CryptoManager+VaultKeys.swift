//
//  CryptoManager+VaultKeys.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Security

// MARK: - Meta Private Key

extension CryptoManager {

    func recoverMetaPrivateKey(password: String?) -> SecKey? {
        if shouldReadVaultKeysFromFiles(),
           let keyID,
           let fileBasedMetaPrivateKey = recoverFileBasedMetaPrivateKey(
            keyID: keyID,
            password: password
           ) {
            return fileBasedMetaPrivateKey
        }

        if let keychainMetaPrivateKey = recoverKeychainMetaPrivateKey(password: password) {
            return keychainMetaPrivateKey
        }

        guard let keyID else {
            return nil
        }

        return recoverFileBasedMetaPrivateKey(
            keyID: keyID,
            password: password
        )
    }

    func recoverKeychainMetaPrivateKey(password: String?) -> SecKey? {
        guard let password, !password.isEmpty else {
            debugLog("Keychain meta private key recovery requires a password", space: .crypto)
            return nil
        }

        return metaKeyStore.recover(
            tag: SecureEnclaveMetaKeyStore.keychainTag,
            password: password
        )
    }

    func recoverFileBasedMetaPrivateKey(keyID: String, password: String?) -> SecKey? {
        guard let password, !password.isEmpty else {
            debugLog("File-based meta private key recovery requires a password", space: .crypto)
            return nil
        }

        return metaKeyStore.recover(
            tag: metaKeyStore.fileBasedTag(keyID: keyID),
            password: password
        )
    }

    func createKeychainMetaPrivateKey(
        _ type: PasswordTypeEnum,
        password: String
    ) throws -> SecKey {
        try metaKeyStore.create(
            passwordType: type,
            tag: SecureEnclaveMetaKeyStore.keychainTag,
            password: password
        )
    }

    @discardableResult
    func deleteKeychainMetaKeypair(password: String) -> Bool {
        metaKeyStore.delete(
            tag: SecureEnclaveMetaKeyStore.keychainTag,
            password: password
        )
    }

    @discardableResult
    func deleteFileBasedMetaKeypair(keyID: String, password: String) -> Bool {
        metaKeyStore.delete(
            tag: metaKeyStore.fileBasedTag(keyID: keyID),
            password: password
        )
    }
}

// MARK: - Vault Key Creation / Recovery

extension CryptoManager {

    func recoverVaultPublicKey() -> SecKey? {
        vaultPrivateKey?.getPublicKey()
    }

    func recoverVaultPrivateKey(password: String?) -> SecKey? {
        guard var keyData = recoverStoredPrivateKeyData() else {
            debugLog("key data not found", space: .crypto)
            return nil
        }

        guard let metaPrivateKey = recoverMetaPrivateKey(password: password) else {
            debugLog("meta private key not recovered", space: .crypto)
            return nil
        }

        guard let decryptedData = metaPrivateKey.eciesDecrypt(keyData) else {
            debugLog("private key data not decrypted", space: .crypto)
            return nil
        }

        keyData = decryptedData

        guard let key = KeyEnum.private.makeSecKey(from: keyData) else {
            return nil
        }

        storeVaultPrivateKey(key)
        return key
    }

    func createVaultPrivateKey() throws -> SecKey {
        try SecKey.createECPrivateKey()
    }

    func recoverStoredPrivateKeyData() -> Data? {
        if shouldReadVaultKeysFromFiles() {
            return cryptoFileManager.recoverKeyData(.privateKey)
        }

        if let data = cryptoKeychainStore.recoverEncryptedPrivateKey() {
            return data
        }

        return cryptoFileManager.recoverKeyData(.privateKey)
    }
}
