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
    
    private var unlockedVaultPrivateKey: SecKey?
    
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
    
    private func storeUnlockedVaultPrivateKey(_ key: SecKey) {
        unlockedVaultPrivateKey = key
    }
    
    func lock() {
        clearUnlockedState()
    }
    
    private func clearUnlockedState() {
        unlockedVaultPrivateKey = nil
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
        guard let unlockedVaultPrivateKey else {
            debugLog("Vault private key is not unlocked", space: .crypto)
            return nil
        }
        
        return unlockedVaultPrivateKey.eciesDecrypt(data)
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
    
    func unlockAndMigrateIfNeeded(password: String?) async -> Bool {
        guard let privateKey = recoverVaultPrivateKey(password: password) else {
            clearUnlockedState()
            return false
        }
        
        storeUnlockedVaultPrivateKey(privateKey)
        
        await migrateFileBasedKeysToKeychainIfNeededAsync(
            password: password,
            vaultKey: privateKey
        )
        
        return true
    }
    
    func withVaultDerivedSQLCipherKey<T>(_ body: (String) throws -> T) throws -> T {
        guard let unlockedVaultPrivateKey,
              var keyString = unlockedVaultPrivateKey.getString() else {
            throw RuntimeError("Vault private key is not unlocked")
        }
        
        defer {
            keyString.removeAll(keepingCapacity: false)
        }
        
        return try body(keyString)
    }
    
    func keysInitialized() -> Bool {
        let hasFileBasedVaultPrivateKey = cryptoFileManager.keyFileExists(.privateKey)
        
        guard hasVaultSetupCompleted() else {
            return hasFileBasedVaultPrivateKey
        }
        
        if hasCompleteKeychainVaultMaterial() {
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
}

// MARK: - Key Initialisation / Update

extension CryptoManager {
    
    func initKeys(_ type: PasswordTypeEnum, password: String) throws {
        debugLog("Creating new crypto keys", space: .crypto)
        
        let privateKey = try createVaultPrivateKey()
        storeUnlockedVaultPrivateKey(privateKey)
        
        do {
            
            _ = deleteKeychainMetaKeypair(password: password)
            
            try saveVaultKeyPairToKeychain(
                passwordType: type,
                password: password
            )
            
            guard let metaPrivateKey = recoverKeychainMetaPrivateKey(password: password),
                  verifyKeychainVaultMatches(
                    vaultKey: privateKey,
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
            clearUnlockedState()
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
        
        guard let oldVaultPrivateKey = recoverVaultPrivateKey(password: oldPassword) else {
            throw RuntimeError("Could not recover vault private key")
        }
        
        storeUnlockedVaultPrivateKey(oldVaultPrivateKey)
        
        do {
            
            try saveVaultKeyPairToKeychain(
                passwordType: type,
                password: newPassword
            )
            
            guard let keychainMetaPrivateKey = recoverKeychainMetaPrivateKey(password: newPassword),
                  verifyKeychainVaultMatches(
                    vaultKey: oldVaultPrivateKey,
                    metaPrivateKey: keychainMetaPrivateKey
                  ) else {
                rollbackKeychainVaultMaterial(password: newPassword)
                throw RuntimeError("Updated key setup verification failed")
            }
            
            _ = deleteKeychainMetaKeypair(password: oldPassword)
            
            passwordType = type
            markVaultKeysMigratedToKeychain()
            markVaultSetupCompleted()
            clearKeyID()
            
        } catch {
            rollbackKeychainVaultMaterial(password: newPassword)
            clearUnlockedState()
            throw error
        }
    }
    
    func saveVaultKeyPairToKeychain(
        passwordType: PasswordTypeEnum,
        password: String
    ) throws {
        guard let privateKey = unlockedVaultPrivateKey else {
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
        unlockedVaultPrivateKey?.getPublicKey()
    }
    
    func recoverVaultPrivateKey(password: String?) -> SecKey? {
        guard let encryptedPrivateKeyData = recoverStoredPrivateKeyData() else {
            debugLog("key data not found", space: .crypto)
            return nil
        }
        
        guard let metaPrivateKey = recoverMetaPrivateKey(password: password) else {
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
        
        guard let key = KeyEnum.private.makeSecKey(from: decryptedPrivateKeyData) else {
            return nil
        }
        
        storeUnlockedVaultPrivateKey(key)
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
        
        guard cryptoKeychainStore.saveEncryptedPrivateKey(encryptedPrivateData) else {
            throw RuntimeError("Failed to save encrypted private key in Keychain")
        }
    }
    
    func verifyKeychainVaultMatches(
        vaultKey: SecKey,
        metaPrivateKey: SecKey
    ) -> Bool {
        guard let encryptedPrivateData = cryptoKeychainStore.recoverEncryptedPrivateKey() else {
            return false
        }
        
        guard var decryptedPrivateData = metaPrivateKey.eciesDecrypt(encryptedPrivateData) else {
            return false
        }
        defer {
            decryptedPrivateData.secureWipe()
        }
        
        guard let recoveredPrivateKey = KeyEnum.private.makeSecKey(from: decryptedPrivateData) else {
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
}

// MARK: - File crypto

extension CryptoManager {
    
    func performFileCrypto(
        inputFileURL: URL,
        outputFileURL: URL,
        operation: CryptoOperationEnum
    ) -> Bool {
        do {
            guard var keyData = fileCryptoKeyData(for: operation) else {
                debugLog("Failed to export key data for file crypto", space: .crypto)
                return false
            }
            defer {
                keyData.secureWipe()
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
            return unlockedVaultPrivateKey?.getData()
        }
    }
}
