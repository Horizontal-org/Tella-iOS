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
    
    static let shared = CryptoManager(
        cryptoFileManager: CryptoFileManager()
    )
    
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
    
    static let metaPrivateKeyTagPrefix = "org.horizontal.tella.ios"
    static let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM
    static let vaultKeysRootPath = "\(NSHomeDirectory())/Documents/keys"
    
    static let keyIDUserDefaultsKey = "keyID"
    
    static let cryptoKeychainMigrationCompletedUserDefaultsKey = "cryptoKeychainMigrationCompleted"
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
        
        await migrateLegacyKeysToKeychainIfNeededAsync(
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
        guard let keyID = UserDefaults.standard.string(forKey: Self.keyIDUserDefaultsKey) else {
            removeKeychainMaterialFromPreviousInstallIfNeeded()
            return false
        }
        
        if hasCompleteKeychainVaultMaterial(keyID: keyID) {
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
        let newKeyID = try saveNewKeyPair(
            privateKey,
            passwordType: type,
            password: password
        )
        
        guard let metaPrivateKey = recoverMetaPrivateKey(password: password),
              verifyKeychainVaultMatches(
                vaultKey: privateKey,
                metaPrivateKey: metaPrivateKey,
                keyID: newKeyID
              ) else {
            rollbackKeychainVaultMaterial(keyID: newKeyID, deleteKeyID: true)
            throw RuntimeError("Fresh key setup verification failed")
        }
        
        vaultPrivateKey = privateKey
        passwordType = type
        markCryptoKeychainMigrationComplete()
    }
    
    func updateKeys(
        _ privateKey: SecKey,
        _ type: PasswordTypeEnum,
        newPassword: String,
        oldPassword: String
    ) throws {
        guard let oldKeyID = resolvedKeyID else {
            throw RuntimeError("Could not find old key ID")
        }
        
        let newKeyID = try saveNewKeyPair(
            privateKey,
            passwordType: type,
            password: newPassword
        )
        
        guard let newMetaPrivateKey = recoverMetaPrivateKey(password: newPassword),
              verifyKeychainVaultMatches(
                vaultKey: privateKey,
                metaPrivateKey: newMetaPrivateKey,
                keyID: newKeyID
              ) else {
            rollbackKeychainVaultMaterial(keyID: newKeyID, deleteKeyID: true)
            throw RuntimeError("Updated key setup verification failed")
        }
        
        passwordType = type
        vaultPrivateKey = privateKey
        
        _ = deleteMetaKeypair(oldKeyID, password: oldPassword)
        markCryptoKeychainMigrationComplete()
    }
    
    @discardableResult
    func saveNewKeyPair(
        _ privateKey: SecKey,
        passwordType: PasswordTypeEnum,
        password: String
    ) throws -> String {
        let newKeyID = UUID().uuidString
        let appTag = metaPrivateKeyTag(newKeyID)
        
        let metaPrivateKey = try createMetaPrivateKey(
            passwordType,
            appTag: appTag,
            password: password
        )
        
        do {
            try writeEncryptedVaultKeypairToKeychain(
                privateKey: privateKey,
                metaPrivateKey: metaPrivateKey,
                keyID: newKeyID
            )
            
            persistVaultKeyID(newKeyID)
            return newKeyID
            
        } catch {
            _ = deleteMetaKeypair(newKeyID, password: password)
            rollbackKeychainVaultMaterial(keyID: newKeyID, deleteKeyID: true)
            throw error
        }
    }
}

// MARK: - Migration

extension CryptoManager {
    
    func migrateLegacyKeysToKeychainIfNeededAsync(
        password: String?,
        vaultKey: SecKey
    ) async {
        await Task.detached(priority: .utility) {
            self.migrateLegacyKeysToKeychainIfNeeded(
                password: password,
                vaultKey: vaultKey
            )
        }.value
    }
    
    func migrateLegacyKeysToKeychainIfNeeded(
        password: String?,
        vaultKey: SecKey
    ) {
        guard let keyID = resolvedKeyID else {
            debugLog("Migration skipped: keyID not found", space: .crypto)
            return
        }
        
        guard let metaPrivateKey = recoverMetaPrivateKey(password: password) else {
            debugLog("Migration skipped: meta private key unavailable", space: .crypto)
            return
        }
        
        if isCryptoKeychainMigrationMarkedComplete {
            deleteLegacyKeyFilesIfPresent(keyID: keyID)
            return
        }
        
        if hasCompleteKeychainVaultMaterial(keyID: keyID),
           verifyKeychainVaultMatches(
            vaultKey: vaultKey,
            metaPrivateKey: metaPrivateKey,
            keyID: keyID
           ) {
            markCryptoKeychainMigrationComplete()
            deleteLegacyKeyFilesIfPresent(keyID: keyID)
            return
        }
        
        guard cryptoFileManager.keyFileExists(.privateKey) else {
            debugLog("Migration skipped: no legacy private key file", space: .crypto)
            return
        }
        
        do {
            try writeEncryptedVaultKeypairToKeychain(
                privateKey: vaultKey,
                metaPrivateKey: metaPrivateKey,
                keyID: keyID
            )
            
            guard verifyKeychainVaultMatches(
                vaultKey: vaultKey,
                metaPrivateKey: metaPrivateKey,
                keyID: keyID
            ) else {
                rollbackKeychainVaultMaterial(keyID: keyID, deleteKeyID: false)
                debugLog("Migration failed: verification failed", space: .crypto)
                return
            }
            
            markCryptoKeychainMigrationComplete()
            deleteLegacyKeyFilesIfPresent(keyID: keyID)
            
        } catch {
            rollbackKeychainVaultMaterial(keyID: keyID, deleteKeyID: false)
            debugLog("Migration failed: \(error)", space: .crypto)
        }
    }
    
    func deleteLegacyKeyFilesIfPresent(keyID: String) {
        guard legacyPrivateKeyFileExists(keyID: keyID) else { return }
        
        cryptoFileManager.deleteKeyFolder(keyID)
        debugLog("Deleted legacy key files for keyID \(keyID)", space: .crypto)
    }
}

// MARK: - Migration Helpers

private extension CryptoManager {
    
    var isCryptoKeychainMigrationMarkedComplete: Bool {
        UserDefaults.standard.bool(
            forKey: Self.cryptoKeychainMigrationCompletedUserDefaultsKey
        )
    }
    
    func markCryptoKeychainMigrationComplete() {
        UserDefaults.standard.set(
            true,
            forKey: Self.cryptoKeychainMigrationCompletedUserDefaultsKey
        )
    }
    
    func hasCompleteKeychainVaultMaterial(keyID: String) -> Bool {
        cryptoKeychainStore.recoverEncryptedPrivateKey(keyID: keyID) != nil &&
        cryptoKeychainStore.recoverPublicKey(keyID: keyID) != nil
    }
    
    func rollbackKeychainVaultMaterial(
        keyID: String,
        deleteKeyID: Bool
    ) {
        _ = cryptoKeychainStore.deleteEncryptedPrivateKey(keyID: keyID)
        _ = cryptoKeychainStore.deletePublicKey(keyID: keyID)
        
        if deleteKeyID {
            _ = cryptoKeychainStore.deleteKeyID()
            UserDefaults.standard.removeObject(forKey: Self.keyIDUserDefaultsKey)
        }
    }
    
    func removeKeychainMaterialFromPreviousInstallIfNeeded() {
        guard let previousInstallKeyID = cryptoKeychainStore.recoverKeyID() else {
            return
        }
        
        debugLog(
            "Found crypto Keychain material from a previous install. Removing it.",
            space: .crypto
        )
        
        _ = cryptoKeychainStore.deleteEncryptedPrivateKey(keyID: previousInstallKeyID)
        _ = cryptoKeychainStore.deletePublicKey(keyID: previousInstallKeyID)
        _ = cryptoKeychainStore.deleteKeyID()
        
        UserDefaults.standard.removeObject(
            forKey: Self.cryptoKeychainMigrationCompletedUserDefaultsKey
        )
        
        unlockedDatabaseKey = nil
        vaultPrivateKey = nil
    }
}

// MARK: - Keychain Write / Verify

private extension CryptoManager {
    
    func writeEncryptedVaultKeypairToKeychain(
        privateKey: SecKey,
        metaPrivateKey: SecKey,
        keyID: String
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
        
        guard cryptoKeychainStore.saveEncryptedPrivateKey(
            encryptedPrivateData,
            keyID: keyID
        ) else {
            throw RuntimeError("Failed to save encrypted private key in Keychain")
        }
        
        guard cryptoKeychainStore.savePublicKey(publicData, keyID: keyID) else {
            _ = cryptoKeychainStore.deleteEncryptedPrivateKey(keyID: keyID)
            throw RuntimeError("Failed to save public key in Keychain")
        }
        
        guard cryptoKeychainStore.saveKeyID(keyID) else {
            _ = cryptoKeychainStore.deleteEncryptedPrivateKey(keyID: keyID)
            _ = cryptoKeychainStore.deletePublicKey(keyID: keyID)
            throw RuntimeError("Failed to save keyID in Keychain")
        }
        
        UserDefaults.standard.set(keyID, forKey: Self.keyIDUserDefaultsKey)
    }
    
    func verifyKeychainVaultMatches(
        vaultKey: SecKey,
        metaPrivateKey: SecKey,
        keyID: String
    ) -> Bool {
        guard let encryptedPrivateData = cryptoKeychainStore.recoverEncryptedPrivateKey(keyID: keyID),
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
              let storedPublicData = cryptoKeychainStore.recoverPublicKey(keyID: keyID),
              originalPublicData == storedPublicData else {
            return false
        }
        
        return true
    }
}

// MARK: - Meta Private Key

private extension CryptoManager {
    
    func recoverMetaPrivateKey(password: String?) -> SecKey? {
        guard let keyID = resolvedKeyID else {
            debugLog("keyID not found", space: .crypto)
            return nil
        }
        
        guard let password, !password.isEmpty else {
            debugLog("Meta private key recovery requires a password", space: .crypto)
            return nil
        }
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(
            metaPrivateKeyQuery(keyID: keyID, password: password) as CFDictionary,
            &item
        )
        
        guard status == errSecSuccess else {
            debugLog(
                "Failed to recover meta private key: \(status.securityMessage)",
                space: .crypto
            )
            return nil
        }
        
        guard let item else {
            debugLog(
                "Meta private key reference missing after keychain lookup",
                space: .crypto
            )
            return nil
        }
        
        guard CFGetTypeID(item) == SecKeyGetTypeID() else {
            debugLog("Keychain item is not a SecKey", space: .crypto)
            return nil
        }
        
        return item as! SecKey
    }
    
    func metaPrivateKeyQuery(
        keyID: String,
        password: String
    ) -> [String: Any] {
        let context = LAContext()
        context.setCredential(Data(password.utf8), type: .applicationPassword)
        
        return [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: metaPrivateKeyTag(keyID),
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecUseAuthenticationContext as String: context
        ]
    }
    
    func createMetaPrivateKey(
        _ type: PasswordTypeEnum,
        appTag: String,
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
                kSecAttrApplicationTag as String: appTag,
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
    func deleteMetaKeypair(_ keyID: String, password: String) -> Bool {
        let status = SecItemDelete(
            metaPrivateKeyQuery(keyID: keyID, password: password) as CFDictionary
        )
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            debugLog(
                "Failed to delete meta private key: \(status.securityMessage)",
                space: .crypto
            )
            return false
        }
        
        return true
    }
}

// MARK: - Vault Key Creation / Recovery Helpers

private extension CryptoManager {
    
    func recoverVaultKey(_ type: KeyEnum, password: String?) -> SecKey? {
        guard let keyID = resolvedKeyID else {
            debugLog("keyID not found", space: .crypto)
            return nil
        }
        
        guard var keyData = recoverStoredKeyData(type, keyID: keyID) else {
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
    
    func recoverStoredKeyData(_ type: KeyEnum, keyID: String) -> Data? {
        switch type {
        case .private:
            return cryptoKeychainStore.recoverEncryptedPrivateKey(keyID: keyID)
            ?? cryptoFileManager.recoverKeyData(.privateKey)
            
        case .public:
            return cryptoKeychainStore.recoverPublicKey(keyID: keyID)
            ?? cryptoFileManager.recoverKeyData(.publicKey)
            
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

// MARK: - Key ID

private extension CryptoManager {
    
    /// Important:
    /// Do not recover keyID from Keychain here.
    /// UserDefaults is the install-scoped source of truth.
    ///
    /// If this returns nil, the current install should be treated as not initialized.
    var resolvedKeyID: String? {
        UserDefaults.standard.string(forKey: Self.keyIDUserDefaultsKey)
    }
    
    func legacyPrivateKeyFileExists(keyID: String) -> Bool {
        let path = "\(Self.vaultKeysRootPath)/\(keyID)/\(KeyFileEnum.privateKey.rawValue)"
        return FileManager.default.fileExists(atPath: path)
    }
    
    func persistVaultKeyID(_ keyID: String) {
        _ = cryptoKeychainStore.saveKeyID(keyID)
        UserDefaults.standard.set(keyID, forKey: Self.keyIDUserDefaultsKey)
    }
    
    func metaPrivateKeyTag(_ keyID: String) -> String {
        "\(Self.metaPrivateKeyTagPrefix).\(keyID)"
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
