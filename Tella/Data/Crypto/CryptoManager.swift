//
//  CryptoManager.swift
//  Tella
//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import LocalAuthentication
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

    private let cryptoFileManager: CryptoFileManagerProtocol
    private let cryptoKeychainStore: CryptoKeychainStoring
    
    private(set) var unlockedDatabaseKey: String?
    private(set) var vaultPrivateKey: SecKey?
    
    @RawValueUserDefaultsProperty("PasswordType", defaultValue: PasswordTypeEnum.tellaPassword)
    var passwordType: PasswordTypeEnum
    
    init(
        cryptoFileManager: CryptoFileManagerProtocol,
        cryptoKeychainStore: CryptoKeychainStoring = CryptoKeychainStore()
    ) {
        self.cryptoFileManager = cryptoFileManager
        self.cryptoKeychainStore = cryptoKeychainStore
    }
}

// MARK: - Constants

private extension CryptoManager {
    
    /// Secure Enclave meta key for Keychain-backed vault keys.
    static let keychainMetaPrivateKeyTag = "org.horizontal.tella.ios"
    
    /// ECIES algorithm used to encrypt and decrypt vault key material with EC key pairs (e.g. meta key wrapping).
    static let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM
    
    /// Folder name under `Documents/keys/` for file-based vault keys.
    static let keyIDUserDefaultsKey = "keyID"
    
    /// Set after vault keys are stored in Keychain (new installs or file-based migration). When true, keys are read from Keychain instead of `Documents/keys/`.
    static let vaultKeysMigratedToKeychainUserDefaultsKey = "cryptoKeychainMigrationCompleted"
   
    /// Set after the first successful vault setup. Cleared when the app is deleted.
    static let vaultSetupCompletedUserDefaultsKey = "vaultSetupCompleted"
}

// MARK: - Public CryptoManagerInterface

extension CryptoManager: CryptoManagerInterface {
    
    func encrypt(_ data: Data) -> Data? {
        guard let publicKey = recoverKey(.public) else {
            debugLog("Failed to recover public key", space: .crypto)
            return nil
        }
        
        return encrypt(data, using: publicKey)
    }
    
    func decrypt(_ data: Data) -> Data? {
        guard let vaultPrivateKey else {
            debugLog("Vault private key is not unlocked", space: .crypto)
            return nil
        }
        
        return decrypt(data, using: vaultPrivateKey)
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
        guard let privateKey = recoverKey(.private, password: password),
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
    
    func recoverKey(_ type: KeyEnum, password: String? = nil) -> SecKey? {
        switch type {
        case .metaPrivate:
            return recoverMetaPrivateKey(password: password)
            
        case .public, .private:
            return recoverVaultKey(type, password: password)
        }
    }
    
    func keysInitialized() -> Bool {
        if hasVaultSetupCompleted() {
            return true
        }
        
        // File-based installs that have not finished migrating to Keychain.
        return cryptoFileManager.keyFileExists(.privateKey)
    }
}

// MARK: - Key Initialisation / Update

extension CryptoManager {
    
    func initKeys(_ type: PasswordTypeEnum, password: String) throws {
        debugLog("Creating new crypto keys", space: .crypto)
        
        let privateKey = try createVaultPrivateKey()
        
        do {
            try saveVaultKeyPairToKeychain(
                privateKey,
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
            
            vaultPrivateKey = privateKey
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
        _ privateKey: SecKey,
        _ type: PasswordTypeEnum,
        newPassword: String,
        oldPassword: String
    ) throws {
        guard recoverMetaPrivateKey(password: oldPassword) != nil else {
            throw RuntimeError("Could not recover old meta private key")
        }
        
        _ = deleteKeychainMetaKeypair(password: oldPassword)
        
        do {
            try saveVaultKeyPairToKeychain(
                privateKey,
                passwordType: type,
                password: newPassword
            )
            
            guard let keychainMetaPrivateKey = recoverKeychainMetaPrivateKey(password: newPassword),
                  verifyKeychainVaultMatches(
                    vaultKey: privateKey,
                    metaPrivateKey: keychainMetaPrivateKey
                  ) else {
                rollbackKeychainVaultMaterial(password: newPassword)
                throw RuntimeError("Updated key setup verification failed")
            }
            
            passwordType = type
            vaultPrivateKey = privateKey
            markVaultKeysMigratedToKeychain()
            markVaultSetupCompleted()
            clearKeyID()
            
        } catch {
            rollbackKeychainVaultMaterial(password: newPassword)
            throw error
        }
    }
    
    func saveVaultKeyPairToKeychain(
        _ privateKey: SecKey,
        passwordType: PasswordTypeEnum,
        password: String
    ) throws {
        _ = deleteKeychainMetaKeypair(password: password)
        
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
        
        let hasFileBasedVaultKeys = cryptoFileManager.keyFileExists(.privateKey)
        
        guard hasFileBasedVaultKeys else {
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

// MARK: - Migration helpers

private extension CryptoManager {
    
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
    
    /// Vault keys still under `Documents/keys/<keyID>/` (not yet in Keychain).
    func shouldReadVaultKeysFromFiles() -> Bool {
        guard !isVaultKeysMigratedToKeychain else {
            return false
        }
        
        return cryptoFileManager.keyFileExists(.privateKey)
    }
    
    func hasCompleteKeychainVaultMaterial() -> Bool {
        cryptoKeychainStore.recoverEncryptedPrivateKey() != nil &&
        cryptoKeychainStore.recoverPublicKey() != nil
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

// MARK: - Keychain Write / Verify

private extension CryptoManager {
    
    func writeEncryptedVaultKeypairToKeychain(
        privateKey: SecKey,
        metaPrivateKey: SecKey
    ) throws {
        let privateData = try externalRepresentation(
            of: privateKey,
            errorMessage: "Failed to export vault private key"
        )
        
        let metaPublicKey = try createMetaPublicKey(from: metaPrivateKey)
        
        guard let encryptedPrivateData = encrypt(privateData, using: metaPublicKey) else {
            throw RuntimeError("Failed to encrypt vault private key")
        }
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw RuntimeError("Failed to create vault public key")
        }
        
        let publicData = try externalRepresentation(
            of: publicKey,
            errorMessage: "Failed to export vault public key"
        )
        
        guard cryptoKeychainStore.saveEncryptedPrivateKey(encryptedPrivateData) else {
            throw RuntimeError("Failed to save encrypted private key in Keychain")
        }
        
        guard cryptoKeychainStore.savePublicKey(publicData) else {
            _ = cryptoKeychainStore.deleteEncryptedPrivateKey()
            throw RuntimeError("Failed to save public key in Keychain")
        }
    }
    
    func verifyKeychainVaultMatches(
        vaultKey: SecKey,
        metaPrivateKey: SecKey
    ) -> Bool {
        guard let encryptedPrivateData = cryptoKeychainStore.recoverEncryptedPrivateKey(),
              let decryptedPrivateData = decrypt(encryptedPrivateData, using: metaPrivateKey),
              let recoveredPrivateKey = makeSecKey(from: decryptedPrivateData, type: .private) else {
            return false
        }
        
        guard let originalPrivateData = externalRepresentationOrNil(vaultKey),
              let recoveredPrivateData = externalRepresentationOrNil(recoveredPrivateKey),
              originalPrivateData == recoveredPrivateData else {
            return false
        }
        
        guard let originalPublicKey = SecKeyCopyPublicKey(vaultKey),
              let originalPublicData = externalRepresentationOrNil(originalPublicKey),
              let storedPublicData = cryptoKeychainStore.recoverPublicKey(),
              originalPublicData == storedPublicData else {
            return false
        }
        
        return true
    }
}

// MARK: - Meta Private Key

private extension CryptoManager {
    
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
        
        return recoverMetaPrivateKey(
            tag: Self.keychainMetaPrivateKeyTag,
            password: password
        )
    }
    
    func recoverFileBasedMetaPrivateKey(keyID: String, password: String?) -> SecKey? {
        guard let password, !password.isEmpty else {
            debugLog("File-based meta private key recovery requires a password", space: .crypto)
            return nil
        }
        
        return recoverMetaPrivateKey(
            tag: fileBasedMetaPrivateKeyTag(keyID),
            password: password
        )
    }
    
    func recoverMetaPrivateKey(tag: String, password: String) -> SecKey? {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(
            metaPrivateKeyQuery(tag: tag, password: password) as CFDictionary,
            &item
        )
        
        guard status == errSecSuccess else {
            if status != errSecItemNotFound {
                debugLog(
                    "Failed to recover meta private key for tag \(tag): \(status.securityMessage)",
                    space: .crypto
                )
            }
            return nil
        }
        
        guard let item else {
            debugLog(
                "Meta private key reference missing after keychain lookup",
                space: .crypto
            )
            return nil
        }

        guard let key = item as? SecKey else {
            debugLog("Keychain item is not a SecKey", space: .crypto)
            return nil
        }

        return key
    }
    
    func metaPrivateKeyQuery(tag: String, password: String) -> [String: Any] {
        let context = LAContext()
        context.setCredential(Data(password.utf8), type: .applicationPassword)
        
        return [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecUseAuthenticationContext as String: context
        ]
    }
    
    func createKeychainMetaPrivateKey(
        _ type: PasswordTypeEnum,
        password: String
    ) throws -> SecKey {
        try createMetaPrivateKey(
            type,
            tag: Self.keychainMetaPrivateKeyTag,
            password: password
        )
    }
    
    func createMetaPrivateKey(
        _ type: PasswordTypeEnum,
        tag: String,
        password: String
    ) throws -> SecKey {
        let context = LAContext()
        context.setCredential(Data(password.utf8), type: .applicationPassword)
        
        guard let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage, type.toFlag()],
            nil
        ) else {
            throw RuntimeError("Failed to create SecAccessControl")
        }
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag,
                kSecAttrAccessControl as String: access
            ],
            kSecUseAuthenticationContext as String: context
        ]
        
        var error: Unmanaged<CFError>?
        
        guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw RuntimeError(
                error?.takeRetainedValue().localizedDescription
                ?? "Failed to create meta private key"
            )
        }
        
        return key
    }
    
    func createMetaPublicKey(from privateKey: SecKey) throws -> SecKey {
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw RuntimeError("Failed to create meta public key")
        }
        
        return publicKey
    }
    
    @discardableResult
    func deleteKeychainMetaKeypair(password: String) -> Bool {
        deleteMetaKeypair(tag: Self.keychainMetaPrivateKeyTag, password: password)
    }
    
    @discardableResult
    func deleteFileBasedMetaKeypair(keyID: String, password: String) -> Bool {
        deleteMetaKeypair(tag: fileBasedMetaPrivateKeyTag(keyID), password: password)
    }
    
    @discardableResult
    func deleteMetaKeypair(tag: String, password: String) -> Bool {
        let status = SecItemDelete(
            metaPrivateKeyQuery(tag: tag, password: password) as CFDictionary
        )
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            debugLog(
                "Failed to delete meta private key for tag \(tag): \(status.securityMessage)",
                space: .crypto
            )
            return false
        }
        
        return true
    }
    
    func fileBasedMetaPrivateKeyTag(_ keyID: String) -> String {
        "\(Self.keychainMetaPrivateKeyTag).\(keyID)"
    }
}

// MARK: - Vault Key Creation / Recovery Helpers

private extension CryptoManager {
    
    func recoverVaultKey(_ type: KeyEnum, password: String?) -> SecKey? {
        guard var keyData = recoverStoredKeyData(type) else {
            debugLog("key data not found", space: .crypto)
            return nil
        }
        
        if type == .private {
            guard let metaPrivateKey = recoverMetaPrivateKey(password: password) else {
                debugLog("meta private key not recovered", space: .crypto)
                return nil
            }
            
            guard let decryptedData = decrypt(keyData, using: metaPrivateKey) else {
                debugLog("private key data not decrypted", space: .crypto)
                return nil
            }
            
            keyData = decryptedData
        }
        
        guard let key = makeSecKey(from: keyData, type: type) else {
            return nil
        }
        
        if type == .private {
            vaultPrivateKey = key
        }
        
        return key
    }
    
    func createVaultPrivateKey() throws -> SecKey {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256
        ]
        
        var error: Unmanaged<CFError>?
        
        guard let privateKey = SecKeyCreateRandomKey(
            attributes as CFDictionary,
            &error
        ) else {
            throw RuntimeError(
                error?.takeRetainedValue().localizedDescription
                ?? "Failed to create vault private key"
            )
        }
        
        return privateKey
    }
    
    func recoverStoredKeyData(_ type: KeyEnum) -> Data? {
        if shouldReadVaultKeysFromFiles() {
            switch type {
            case .private:
                return cryptoFileManager.recoverKeyData(.privateKey)
            case .public:
                return cryptoFileManager.recoverKeyData(.publicKey)
            case .metaPrivate:
                return nil
            }
        }
        
        switch type {
        case .private:
            if let data = cryptoKeychainStore.recoverEncryptedPrivateKey() {
                return data
            }
            
            return cryptoFileManager.recoverKeyData(.privateKey)
            
        case .public:
            if let data = cryptoKeychainStore.recoverPublicKey() {
                return data
            }
            
            return cryptoFileManager.recoverKeyData(.publicKey)
            
        case .metaPrivate:
            return nil
        }
    }
    
    func makeSecKey(from data: Data, type: KeyEnum) -> SecKey? {
        var error: Unmanaged<CFError>?
        
        guard let key = SecKeyCreateWithData(
            data as CFData,
            keyOptions(for: type) as CFDictionary,
            &error
        ) else {
            debugLog(
                "Failed to create SecKey: \(error?.takeRetainedValue().localizedDescription ?? "")",
                space: .crypto
            )
            return nil
        }
        
        return key
    }
    
    func keyOptions(for type: KeyEnum) -> [String: Any] {
        switch type {
        case .metaPrivate:
            return [
                kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits as String: 256,
                kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave
            ]
            
        case .public:
            return [
                kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits as String: 256
            ]
            
        case .private:
            return [
                kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits as String: 256
            ]
        }
    }
    
    func externalRepresentation(
        of key: SecKey,
        errorMessage: String
    ) throws -> Data {
        var error: Unmanaged<CFError>?
        
        guard let data = SecKeyCopyExternalRepresentation(
            key,
            &error
        ) as Data? else {
            throw RuntimeError(
                error?.takeRetainedValue().localizedDescription
                ?? errorMessage
            )
        }
        
        return data
    }
    
    func externalRepresentationOrNil(_ key: SecKey) -> Data? {
        SecKeyCopyExternalRepresentation(key, nil) as Data?
    }
}

// MARK: - SecKey Encryption / Decryption

private extension CryptoManager {
    
    func encrypt(_ data: Data, using publicKey: SecKey) -> Data? {
        guard SecKeyIsAlgorithmSupported(
            publicKey,
            .encrypt,
            Self.algorithm
        ) else {
            debugLog("Algorithm is not supported for encryption", space: .crypto)
            return nil
        }
        
        var error: Unmanaged<CFError>?
        
        guard let encryptedData = SecKeyCreateEncryptedData(
            publicKey,
            Self.algorithm,
            data as CFData,
            &error
        ) as Data? else {
            debugLog(
                "Encryption failed: \(error?.takeRetainedValue().localizedDescription ?? "")",
                space: .crypto
            )
            return nil
        }
        
        return encryptedData
    }
    
    func decrypt(_ data: Data, using privateKey: SecKey) -> Data? {
        guard SecKeyIsAlgorithmSupported(
            privateKey,
            .decrypt,
            Self.algorithm
        ) else {
            debugLog("Algorithm is not supported for decryption", space: .crypto)
            return nil
        }
        
        var error: Unmanaged<CFError>?
        
        guard let decryptedData = SecKeyCreateDecryptedData(
            privateKey,
            Self.algorithm,
            data as CFData,
            &error
        ) as Data? else {
            debugLog(
                "Decryption failed: \(error?.takeRetainedValue().localizedDescription ?? "")",
                space: .crypto
            )
            return nil
        }
        
        return decryptedData
    }
}

// MARK: - File Crypto

private extension CryptoManager {
    
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
            return recoverKey(.public)?.getData()
            
        case .decrypt:
            return vaultPrivateKey?.getData()
        }
    }
}

// MARK: - OSStatus Helper

private extension OSStatus {
    
    var securityMessage: String {
        SecCopyErrorMessageString(self, nil) as String? ?? "\(self)"
    }
}

// MARK: - Backward Compatibility Aliases

extension KeyEnum {
    
    static var META_PRIVATE: KeyEnum { .metaPrivate }
    static var PUBLIC: KeyEnum { .public }
    static var PRIVATE: KeyEnum { .private }
}

extension KeyFileEnum {
    
    static var PUBLIC: KeyFileEnum { .publicKey }
    static var PRIVATE: KeyFileEnum { .privateKey }
}
