//
//  CryptoManager+Migration.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Security

// MARK: - File-based → Keychain migration

extension CryptoManager {

    func migrateFileBasedKeysToKeychainIfNeededAsync(
        password: String?,
        vaultKey: SecKey
    ) async {
        await Task.detached(priority: .utility) {
            self.migrateFileBasedKeysToKeychainIfNeeded(
                password: password,
                vaultKey: vaultKey
            )
        }.value
    }

    func migrateFileBasedKeysToKeychainIfNeeded(
        password: String?,
        vaultKey: SecKey
    ) {
        guard let password, !password.isEmpty else {
            debugLog("Migration skipped: password unavailable", space: .crypto)
            return
        }

        if isVaultKeysMigratedToKeychain,
           hasCompleteKeychainVaultMaterial(),
           let keychainMetaPrivateKey = recoverKeychainMetaPrivateKey(password: password),
           verifyKeychainVaultMatches(
            vaultKey: vaultKey,
            metaPrivateKey: keychainMetaPrivateKey
           ) {
            markVaultSetupCompleted()
            deleteVaultKeyFilesIfPresent()
            return
        }

        if hasCompleteKeychainVaultMaterial(),
           let keychainMetaPrivateKey = recoverKeychainMetaPrivateKey(password: password),
           verifyKeychainVaultMatches(
            vaultKey: vaultKey,
            metaPrivateKey: keychainMetaPrivateKey
           ) {
            markVaultKeysMigratedToKeychain()
            markVaultSetupCompleted()
            deleteVaultKeyFilesIfPresent()
            return
        }

        guard cryptoFileManager.keyFileExists(.privateKey) else {
            debugLog("Migration skipped: no file-based vault keys", space: .crypto)
            return
        }

        do {
            let keychainMetaPrivateKey: SecKey

            if let existingKeychainMetaPrivateKey = recoverKeychainMetaPrivateKey(password: password) {
                keychainMetaPrivateKey = existingKeychainMetaPrivateKey
            } else {
                keychainMetaPrivateKey = try createKeychainMetaPrivateKey(
                    passwordType,
                    password: password
                )
            }

            try writeEncryptedVaultKeypairToKeychain(
                privateKey: vaultKey,
                metaPrivateKey: keychainMetaPrivateKey
            )

            guard verifyKeychainVaultMatches(
                vaultKey: vaultKey,
                metaPrivateKey: keychainMetaPrivateKey
            ) else {
                rollbackKeychainVaultMaterial(password: password)
                debugLog("Migration failed: verification failed", space: .crypto)
                return
            }

            markVaultKeysMigratedToKeychain()
            markVaultSetupCompleted()
            deleteVaultKeyFilesIfPresent()

        } catch {
            rollbackKeychainVaultMaterial(password: password)
            debugLog("Migration failed: \(error)", space: .crypto)
        }
    }

    func deleteVaultKeyFilesIfPresent() {
        guard let keyID else {
            return
        }

        cryptoFileManager.deleteKeyFolder(keyID)
        clearKeyID()
        debugLog("Deleted file-based vault keys for keyID \(keyID)", space: .crypto)
    }
}

// MARK: - Migration state

extension CryptoManager {

    var isVaultKeysMigratedToKeychain: Bool {
        UserDefaults.standard.bool(
            forKey: Self.vaultKeysMigratedToKeychainUserDefaultsKey
        )
    }

    func markVaultKeysMigratedToKeychain() {
        UserDefaults.standard.set(
            true,
            forKey: Self.vaultKeysMigratedToKeychainUserDefaultsKey
        )
    }

    func hasVaultSetupCompleted() -> Bool {
        UserDefaults.standard.bool(forKey: Self.vaultSetupCompletedUserDefaultsKey)
    }

    func markVaultSetupCompleted() {
        UserDefaults.standard.set(
            true,
            forKey: Self.vaultSetupCompletedUserDefaultsKey
        )
    }

    func shouldReadVaultKeysFromFiles() -> Bool {
        guard !isVaultKeysMigratedToKeychain else {
            return false
        }

        return cryptoFileManager.keyFileExists(.privateKey)
    }

    func hasCompleteKeychainVaultMaterial() -> Bool {
        cryptoKeychainStore.recoverEncryptedPrivateKey() != nil
    }

    func rollbackKeychainVaultMaterial(password: String) {
        _ = cryptoKeychainStore.deleteVaultKeyMaterial()
        _ = deleteKeychainMetaKeypair(password: password)
    }

    var keyID: String? {
        UserDefaults.standard.string(forKey: Self.keyIDUserDefaultsKey)
    }

    func clearKeyID() {
        UserDefaults.standard.removeObject(forKey: Self.keyIDUserDefaultsKey)
    }
}

// MARK: - Keychain write / verify

extension CryptoManager {

    func writeEncryptedVaultKeypairToKeychain(
        privateKey: SecKey,
        metaPrivateKey: SecKey
    ) throws {
        let privateData = try privateKey.externalRepresentationOrThrow(
            "Failed to export vault private key"
        )

        guard let metaPublicKey = metaPrivateKey.getPublicKey() else {
            throw RuntimeError("Failed to create meta public key")
        }

        guard let encryptedPrivateData = metaPublicKey.eciesEncrypt(privateData) else {
            throw RuntimeError("Failed to encrypt vault private key")
        }

        guard cryptoKeychainStore.saveEncryptedPrivateKey(encryptedPrivateData) else {
            throw RuntimeError("Failed to save encrypted private key in Keychain")
        }
    }

    func verifyKeychainVaultMatches(
        vaultKey: SecKey,
        metaPrivateKey: SecKey
    ) -> Bool {
        guard let encryptedPrivateData = cryptoKeychainStore.recoverEncryptedPrivateKey(),
              let decryptedPrivateData = metaPrivateKey.eciesDecrypt(encryptedPrivateData),
              let recoveredPrivateKey = KeyEnum.private.makeSecKey(from: decryptedPrivateData) else {
            return false
        }

        guard let originalPrivateData = vaultKey.getData(),
              let recoveredPrivateData = recoveredPrivateKey.getData(),
              originalPrivateData == recoveredPrivateData else {
            return false
        }

        return recoveredPrivateKey.getPublicKey() != nil
    }
}

// MARK: - File crypto

extension CryptoManager {

    func performFileCrypto(
        inputFileURL: URL,
        outputFileURL: URL,
        operation: CryptoOperationEnum
    ) -> Bool {
        do {
            guard let keyData = fileCryptoKeyData(for: operation) else {
                debugLog("Failed to export key data for file crypto", space: .crypto)
                return false
            }

            let fileCryptor = try FileCryptor(
                inputFileURL: inputFileURL,
                outputFileURL: outputFileURL,
                encryptionKeyData: keyData,
                cryptoOperation: operation
            )

            try fileCryptor.cryptFile()
            return true

        } catch {
            debugLog("File crypto failed: \(error)", space: .crypto)
            return false
        }
    }

    func fileCryptoKeyData(for operation: CryptoOperationEnum) -> Data? {
        switch operation {
        case .encrypt:
            return recoverVaultPublicKey()?.getData()

        case .decrypt:
            return vaultPrivateKey?.getData()
        }
    }
}
