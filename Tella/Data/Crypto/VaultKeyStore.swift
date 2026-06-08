//
//  VaultKeyStore.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Security

protocol VaultKeyStoring: AnyObject {
    var passwordType: PasswordTypeEnum { get set }
    func keysInitialized() -> Bool
    func unlock(password: String?) -> SecKey?
    func setup(type: PasswordTypeEnum, password: String) throws -> SecKey
    func changePassword(
        type: PasswordTypeEnum,
        newPassword: String,
        oldPassword: String
    ) throws
    func migrateIfNeededAsync(password: String?, vaultKey: SecKey) async
}

final class VaultKeyStore: VaultKeyStoring {

    private let cryptoFileManager: CryptoFileManagerProtocol
    private let cryptoKeychainStore: CryptoKeychainStoring
    private let metaKeyStore: SecureEnclaveMetaKeyStoring
    private let vaultKeyPairStore: VaultKeyPairStoring
    private let vaultKeyMigrator: VaultKeyMigrating

    @UserDefaultsProperty(key: VaultUserDefaultsKey.keyID)
    private var keyID: String?

    @BoolUserDefaultsProperty(VaultUserDefaultsKey.vaultSetupCompleted)
    private var vaultSetupCompleted

    @BoolUserDefaultsProperty(VaultUserDefaultsKey.cryptoKeychainMigrationCompleted)
    private var vaultKeysMigratedToKeychain

    @RawValueUserDefaultsProperty(VaultUserDefaultsKey.passwordType, defaultValue: PasswordTypeEnum.tellaPassword)
    var passwordType: PasswordTypeEnum

    init(
        cryptoFileManager: CryptoFileManagerProtocol,
        cryptoKeychainStore: CryptoKeychainStoring,
        metaKeyStore: SecureEnclaveMetaKeyStoring,
        vaultKeyPairStore: VaultKeyPairStoring? = nil,
        vaultKeyMigrator: VaultKeyMigrating? = nil
    ) {
        self.cryptoFileManager = cryptoFileManager
        self.cryptoKeychainStore = cryptoKeychainStore
        self.metaKeyStore = metaKeyStore

        let pairStore = vaultKeyPairStore ?? VaultKeyPairStore(
            cryptoKeychainStore: cryptoKeychainStore,
            metaKeyStore: metaKeyStore
        )
        self.vaultKeyPairStore = pairStore

        self.vaultKeyMigrator = vaultKeyMigrator ?? VaultKeyMigrator(
            cryptoFileManager: cryptoFileManager,
            cryptoKeychainStore: cryptoKeychainStore,
            metaKeyStore: metaKeyStore,
            vaultKeyPairStore: pairStore
        )
    }

    func keysInitialized() -> Bool {
        let hasFileBasedVaultPrivateKey = cryptoFileManager.keyFileExists(.privateKey)

        guard vaultSetupCompleted else {
            return hasFileBasedVaultPrivateKey
        }

        if vaultKeyMigrator.hasCompleteKeychainVaultMaterial() {
            return true
        }

        if hasFileBasedVaultPrivateKey {
            debugLog(
                "Vault setup flag exists, but Keychain vault material is missing; using legacy file-based key material",
                space: .crypto
            )
            return true
        }

        debugLog(
            "Vault setup flag exists, but no vault key material was found",
            space: .crypto
        )
        return false
    }

    func unlock(password: String?) -> SecKey? {
        recoverVaultPrivateKey(password: password)
    }

    func setup(type: PasswordTypeEnum, password: String) throws -> SecKey {
        debugLog("Creating new crypto keys", space: .crypto)

        do {
            if let existingKeyID = keyID {
                _ = metaKeyStore.delete(
                    tag: metaKeyStore.metaKeyTag(for: existingKeyID),
                    password: password
                )
                cryptoFileManager.deleteKeysRootFolder()
            }

            keyID = makeKeyID()

            guard let keyID else {
                throw RuntimeError("Missing key ID")
            }

            let vaultPrivateKey = try SecKey.createECPrivateKey()
            let metaPrivateKey = try metaKeyStore.create(
                passwordType: type,
                tag: metaKeyStore.metaKeyTag(for: keyID),
                password: password
            )

            try vaultKeyPairStore.writeEncryptedVaultKeypair(
                privateKey: vaultPrivateKey,
                metaPrivateKey: metaPrivateKey
            )

            guard let verifiedKey = recoverVaultPrivateKey(password: password) else {
                throw RuntimeError("Fresh key setup verification failed")
            }

            passwordType = type
            vaultKeysMigratedToKeychain = true
            vaultSetupCompleted = true

            return verifiedKey

        } catch {
            vaultKeyPairStore.rollback(password: password, keyID: keyID)
            throw error
        }
    }

    func changePassword(
        type: PasswordTypeEnum,
        newPassword: String,
        oldPassword: String
    ) throws {
        guard !newPassword.isEmpty else {
            throw RuntimeError("New password is empty")
        }

        guard !oldPassword.isEmpty else {
            throw RuntimeError("Old password is empty")
        }

        guard let oldKeyID = keyID else {
            throw RuntimeError("Could not find key ID")
        }

        guard let vaultPrivateKey = recoverVaultPrivateKey(password: oldPassword) else {
            throw RuntimeError("Could not recover vault private key")
        }

        let newKeyID = makeKeyID()

        do {
            let metaPrivateKey = try metaKeyStore.create(
                passwordType: type,
                tag: metaKeyStore.metaKeyTag(for: newKeyID),
                password: newPassword
            )

            try vaultKeyPairStore.writeEncryptedVaultKeypair(
                privateKey: vaultPrivateKey,
                metaPrivateKey: metaPrivateKey
            )

            guard vaultKeyPairStore.verifyKeychainVaultMatches(
                vaultKey: vaultPrivateKey,
                metaPrivateKey: metaPrivateKey
            ) else {
                throw RuntimeError("Updated key setup verification failed")
            }

            keyID = newKeyID
            _ = metaKeyStore.delete(
                tag: metaKeyStore.metaKeyTag(for: oldKeyID),
                password: oldPassword
            )

            passwordType = type
            vaultKeysMigratedToKeychain = true
            vaultSetupCompleted = true

        } catch {
            _ = metaKeyStore.delete(
                tag: metaKeyStore.metaKeyTag(for: newKeyID),
                password: newPassword
            )
            throw error
        }
    }

    func migrateIfNeededAsync(password: String?, vaultKey: SecKey) async {
        await vaultKeyMigrator.migrateIfNeededAsync(
            password: password,
            vaultKey: vaultKey,
            passwordType: passwordType
        )
    }

    private func recoverVaultPrivateKey(password: String?) -> SecKey? {
        guard let encryptedPrivateKeyData = recoverStoredPrivateKeyData() else {
            debugLog("key data not found", space: .crypto)
            return nil
        }

        guard let password, !password.isEmpty else {
            return nil
        }

        guard let metaPrivateKey = metaKeyStore.recoverMetaPrivateKey(
            keyID: keyID,
            password: password
        ) else {
            debugLog("meta private key not recovered", space: .crypto)
            return nil
        }

        guard var decryptedPrivateKeyData = metaPrivateKey.eciesDecrypt(encryptedPrivateKeyData) else {
            debugLog("private key data not decrypted", space: .crypto)
            return nil
        }

        defer {
            decryptedPrivateKeyData.secureWipe()
        }

        return SecKey.makeKey(
            from: decryptedPrivateKeyData,
            options: [
                kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits as String: 256
            ]
        )
    }

    private func recoverStoredPrivateKeyData() -> Data? {
        if shouldReadVaultKeysFromFiles() {
            return cryptoFileManager.recoverKeyData(.privateKey)
        }

        if let data = cryptoKeychainStore.recoverEncryptedPrivateKey() {
            return data
        }

        return cryptoFileManager.recoverKeyData(.privateKey)
    }

    private func shouldReadVaultKeysFromFiles() -> Bool {
        guard !vaultKeysMigratedToKeychain else {
            return false
        }

        return cryptoFileManager.keyFileExists(.privateKey)
    }

    private func makeKeyID() -> String {
        UUID().uuidString
    }
}
