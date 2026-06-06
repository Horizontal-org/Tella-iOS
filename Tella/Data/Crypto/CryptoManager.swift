//
//  CryptoManager.swift
//  Tella
//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import CommonCrypto
import Security

enum CryptoOperationEnum {
    case encrypt
    case decrypt
}

protocol CryptoManagerInterface {
    func encrypt(_ data: Data) -> Data?
    func decrypt(_ data: Data) -> Data?
    func encryptFile(at inputFileURL: URL, outputTo outputFileURL: URL) -> Bool
    func decryptFile(at inputFileURL: URL, outputTo outputFileURL: URL) -> Bool
}

enum KeyEnum {
    case metaPrivate
    case `public`
    case `private`
}

enum KeyFileEnum: String {
    case publicKey = "pub-key.txt"
    case privateKey = "priv-key.txt"
}

final class CryptoManager {

    let cryptoFileManager: CryptoFileManagerProtocol
    let cryptoKeychainStore: CryptoKeychainStoring
    let metaKeyStore: SecureEnclaveMetaKeyStoring

    private(set) var unlockedDatabaseKey: String?
    private(set) var vaultPrivateKey: SecKey?

    @RawValueUserDefaultsProperty("PasswordType", defaultValue: PasswordTypeEnum.tellaPassword)
    var passwordType: PasswordTypeEnum

    init(
        cryptoFileManager: CryptoFileManagerProtocol,
        cryptoKeychainStore: CryptoKeychainStoring = CryptoKeychainStore(),
        metaKeyStore: SecureEnclaveMetaKeyStoring = SecureEnclaveMetaKeyStore()
    ) {
        self.cryptoFileManager = cryptoFileManager
        self.cryptoKeychainStore = cryptoKeychainStore
        self.metaKeyStore = metaKeyStore
    }

    func storeVaultPrivateKey(_ key: SecKey) {
        vaultPrivateKey = key
    }
}

// MARK: - Constants

extension CryptoManager {

    static let keyIDUserDefaultsKey = "keyID"
    static let vaultKeysMigratedToKeychainUserDefaultsKey = "cryptoKeychainMigrationCompleted"
    static let vaultSetupCompletedUserDefaultsKey = "vaultSetupCompleted"
}

// MARK: - Public CryptoManagerInterface

extension CryptoManager: CryptoManagerInterface {

    func encrypt(_ data: Data) -> Data? {
        guard let publicKey = recoverVaultPublicKey() else {
            debugLog("Vault public key is not available", space: .crypto)
            return nil
        }

        return publicKey.eciesEncrypt(data)
    }

    func decrypt(_ data: Data) -> Data? {
        guard let vaultPrivateKey else {
            debugLog("Vault private key is not unlocked", space: .crypto)
            return nil
        }

        return vaultPrivateKey.eciesDecrypt(data)
    }

    func encryptFile(at inputFileURL: URL, outputTo outputFileURL: URL) -> Bool {
        performFileCrypto(
            inputFileURL: inputFileURL,
            outputFileURL: outputFileURL,
            operation: .encrypt
        )
    }

    func decryptFile(at inputFileURL: URL, outputTo outputFileURL: URL) -> Bool {
        performFileCrypto(
            inputFileURL: inputFileURL,
            outputFileURL: outputFileURL,
            operation: .decrypt
        )
    }
}

// MARK: - Unlock

extension CryptoManager {

    func unlockAndMigrateIfNeeded(password: String?) async -> String? {
        guard let privateKey = recoverVaultPrivateKey(password: password),
              let keyString = privateKey.getString() else {
            return nil
        }

        await MainActor.run {
            self.unlockedDatabaseKey = keyString
        }

        await migrateFileBasedKeysToKeychainIfNeededAsync(
            password: password,
            vaultKey: privateKey
        )

        return keyString
    }

    func keysInitialized() -> Bool {
        if hasVaultSetupCompleted() {
            return true
        }

        return cryptoFileManager.keyFileExists(.privateKey)
    }
}

// MARK: - Key Initialisation / Update

extension CryptoManager {

    func initKeys(_ type: PasswordTypeEnum, password: String) throws {
        debugLog("Creating new crypto keys", space: .crypto)

        let privateKey = try createVaultPrivateKey()
        storeVaultPrivateKey(privateKey)

        do {
            
            _ = deleteKeychainMetaKeypair(password: password)

            try saveVaultKeyPairToKeychain(
                passwordType: type,
                password: password
            )

            guard let metaPrivateKey = recoverKeychainMetaPrivateKey(password: password),
                  let vaultPrivateKey,
                  verifyKeychainVaultMatches(
                    vaultKey: vaultPrivateKey,
                    metaPrivateKey: metaPrivateKey
                  ) else {
                rollbackKeychainVaultMaterial(password: password)
                throw RuntimeError("Fresh key setup verification failed")
            }

            passwordType = type
            markVaultKeysMigratedToKeychain()
            markVaultSetupCompleted()
            clearKeyID()

        } catch {
            rollbackKeychainVaultMaterial(password: password)
            throw error
        }
    }

    func updateKeys(
        _ type: PasswordTypeEnum,
        newPassword: String,
        oldPassword: String
    ) throws {
        guard recoverMetaPrivateKey(password: oldPassword) != nil else {
            throw RuntimeError("Could not recover old meta private key")
        }

        guard recoverVaultPrivateKey(password: oldPassword) != nil else {
            throw RuntimeError("Could not recover vault private key")
        }

        do {

            try saveVaultKeyPairToKeychain(
                passwordType: type,
                password: newPassword
            )
            
            _ = deleteKeychainMetaKeypair(password: oldPassword)

            guard let keychainMetaPrivateKey = recoverKeychainMetaPrivateKey(password: newPassword),
                  let vaultPrivateKey,
                  verifyKeychainVaultMatches(
                    vaultKey: vaultPrivateKey,
                    metaPrivateKey: keychainMetaPrivateKey
                  ) else {
                rollbackKeychainVaultMaterial(password: newPassword)
                throw RuntimeError("Updated key setup verification failed")
            }

            passwordType = type
            markVaultKeysMigratedToKeychain()
            markVaultSetupCompleted()
            clearKeyID()

        } catch {
            rollbackKeychainVaultMaterial(password: newPassword)
            throw error
        }
    }

    func saveVaultKeyPairToKeychain(
        passwordType: PasswordTypeEnum,
        password: String
    ) throws {
        guard let privateKey = vaultPrivateKey else {
            throw RuntimeError("Vault private key is not available")
        }

        let metaPrivateKey = try createKeychainMetaPrivateKey(
            passwordType,
            password: password
        )

        do {
            try writeEncryptedVaultKeypairToKeychain(
                privateKey: privateKey,
                metaPrivateKey: metaPrivateKey
            )
        } catch {
            rollbackKeychainVaultMaterial(password: password)
            throw error
        }
    }
}
