//
//  VaultKeyMigrator.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Security

protocol VaultKeyMigrating: AnyObject {
    func migrateIfNeededAsync(
        password: String?,
        vaultKey: SecKey,
        passwordType: PasswordTypeEnum
    ) async
    func hasCompleteKeychainVaultMaterial() -> Bool
}

final class VaultKeyMigrator: VaultKeyMigrating {

    private let cryptoFileManager: CryptoFileManagerProtocol
    private let cryptoKeychainStore: CryptoKeychainStoring
    private let metaKeyStore: SecureEnclaveMetaKeyStoring
    private let vaultKeyPairStore: VaultKeyPairStoring

    @UserDefaultsProperty(key: VaultUserDefaultsKey.keyID)
    private var keyID: String?

    @BoolUserDefaultsProperty(VaultUserDefaultsKey.vaultSetupCompleted)
    private var vaultSetupCompleted

    @BoolUserDefaultsProperty(VaultUserDefaultsKey.cryptoKeychainMigrationCompleted)
    private var vaultKeysMigratedToKeychain

    init(
        cryptoFileManager: CryptoFileManagerProtocol,
        cryptoKeychainStore: CryptoKeychainStoring,
        metaKeyStore: SecureEnclaveMetaKeyStoring,
        vaultKeyPairStore: VaultKeyPairStoring
    ) {
        self.cryptoFileManager = cryptoFileManager
        self.cryptoKeychainStore = cryptoKeychainStore
        self.metaKeyStore = metaKeyStore
        self.vaultKeyPairStore = vaultKeyPairStore
    }

    func migrateIfNeededAsync(
        password: String?,
        vaultKey: SecKey,
        passwordType: PasswordTypeEnum
    ) async {
        await Task.detached(priority: .utility) {
            self.migrateIfNeeded(
                password: password,
                vaultKey: vaultKey,
                passwordType: passwordType
            )
        }.value
    }

    func hasCompleteKeychainVaultMaterial() -> Bool {
        cryptoKeychainStore.recoverEncryptedPrivateKey() != nil
    }

    private func migrateIfNeeded(
        password: String?,
        vaultKey: SecKey,
        passwordType: PasswordTypeEnum
    ) {
        guard let password, !password.isEmpty else {
            debugLog("Migration skipped: password unavailable", space: .crypto)
            return
        }

        if vaultKeysMigratedToKeychain,
           hasCompleteKeychainVaultMaterial(),
           let metaPrivateKey = recoverMetaPrivateKey(password: password),
           vaultKeyPairStore.verifyKeychainVaultMatches(
               vaultKey: vaultKey,
               metaPrivateKey: metaPrivateKey
           ) {
            vaultSetupCompleted = true
            deleteVaultKeyFilesIfPresent()
            return
        }

        if hasCompleteKeychainVaultMaterial(),
           let metaPrivateKey = recoverMetaPrivateKey(password: password),
           vaultKeyPairStore.verifyKeychainVaultMatches(
               vaultKey: vaultKey,
               metaPrivateKey: metaPrivateKey
           ) {
            vaultKeysMigratedToKeychain = true
            vaultSetupCompleted = true
            deleteVaultKeyFilesIfPresent()
            return
        }

        guard cryptoFileManager.keyFileExists(.privateKey) else {
            debugLog("Migration skipped: no file-based vault keys", space: .crypto)
            return
        }

        do {
            if keyID == nil {
                keyID = makeKeyID()
            }

            guard let keyID else {
                throw RuntimeError("Missing key ID")
            }

            let metaPrivateKey: SecKey

            if let existingMetaPrivateKey = recoverMetaPrivateKey(password: password) {
                metaPrivateKey = existingMetaPrivateKey
            } else {
                metaPrivateKey = try metaKeyStore.create(
                    passwordType: passwordType,
                    keyID: keyID,
                    password: password
                )
            }

            try vaultKeyPairStore.writeEncryptedVaultKeypair(
                privateKey: vaultKey,
                metaPrivateKey: metaPrivateKey
            )

            guard vaultKeyPairStore.verifyKeychainVaultMatches(
                vaultKey: vaultKey,
                metaPrivateKey: metaPrivateKey
            ) else {
                vaultKeyPairStore.rollback(password: password, keyID: keyID)
                debugLog("Migration failed: verification failed", space: .crypto)
                return
            }

            vaultKeysMigratedToKeychain = true
            vaultSetupCompleted = true
            deleteVaultKeyFilesIfPresent()

        } catch {
            vaultKeyPairStore.rollback(password: password, keyID: keyID)
            debugLog("Migration failed: \(error)", space: .crypto)
        }
    }

    private func recoverMetaPrivateKey(password: String) -> SecKey? {
        metaKeyStore.recoverMetaPrivateKey(
            keyID: keyID,
            password: password
        )
    }

    private func deleteVaultKeyFilesIfPresent() {
        cryptoFileManager.deleteKeysRootFolder()
        debugLog("Deleted file-based vault keys folder", space: .crypto)
    }

    private func makeKeyID() -> String {
        UUID().uuidString
    }
}
