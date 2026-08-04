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

final class CryptoManager {
    
    let vaultKeyStore: VaultKeyStoring
    
    private var unlockedVaultPrivateKey: SecKey?
    
    var passwordType: PasswordTypeEnum {
        get { vaultKeyStore.passwordType }
        set { vaultKeyStore.passwordType = newValue }
    }
    
    init(
        cryptoFileManager: CryptoFileManagerProtocol,
        keychainStore: VaultKeychainStoring = CryptoKeychainStore(),
        vaultKeyStore: VaultKeyStoring? = nil
    ) {
        self.vaultKeyStore = vaultKeyStore ?? VaultKeyStore(
            cryptoFileManager: cryptoFileManager,
            keychainStore: keychainStore
        )
    }
    
    var isUnlocked: Bool {
        unlockedVaultPrivateKey != nil
    }
    
    func lock() {
        unlockedVaultPrivateKey = nil
    }
}

// MARK: - VaultLockManaging

protocol VaultLockManaging: AnyObject {
    var passwordType: PasswordTypeEnum { get set }
    var isUnlocked: Bool { get }
    func unlockAndMigrateIfNeeded(password: String?) async -> Bool
    func keysInitialized() -> Bool
    func initKeys(_ type: PasswordTypeEnum, password: String) throws
    func updateKeys(
        _ type: PasswordTypeEnum,
        newPassword: String,
        oldPassword: String
    ) throws
    func lock()
    func withVaultDerivedSQLCipherKey<T>(_ body: (String) throws -> T) throws -> T
}

typealias VaultCryptoManaging = CryptoManagerInterface & VaultLockManaging

extension CryptoManager: VaultLockManaging {
    
    func unlockAndMigrateIfNeeded(password: String?) async -> Bool {
        guard let privateKey = vaultKeyStore.unlock(password: password) else {
            lock()
            return false
        }
        
        unlockedVaultPrivateKey = privateKey
        
        await vaultKeyStore.migrateIfNeededAsync(
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
        vaultKeyStore.keysInitialized()
    }
    
    func initKeys(_ type: PasswordTypeEnum, password: String) throws {
        do {
            unlockedVaultPrivateKey = try vaultKeyStore.setup(
                type: type,
                password: password
            )
        } catch {
            lock()
            throw error
        }
    }
    
    func updateKeys(
        _ type: PasswordTypeEnum,
        newPassword: String,
        oldPassword: String
    ) throws {
        try vaultKeyStore.changePassword(
            type: type,
            newPassword: newPassword,
            oldPassword: oldPassword
        )
    }
}

// MARK: - Public CryptoManagerInterface

protocol CryptoManagerInterface {
    func decrypt(_ data: Data) -> Data?
    func encryptFile(at inputFileURL: URL, outputTo outputFileURL: URL) -> Bool
    func decryptFile(at inputFileURL: URL, outputTo outputFileURL: URL) -> Bool
}

enum CryptoOperationEnum {
    case encrypt
    case decrypt
}

extension CryptoManager: CryptoManagerInterface {
    
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
    
    private func performFileCrypto(
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
    
    private func fileCryptoKeyData(for operation: CryptoOperationEnum) -> Data? {
        switch operation {
        case .encrypt:
            return unlockedVaultPrivateKey?.getPublicKey()?.getData()
            
        case .decrypt:
            return unlockedVaultPrivateKey?.getData()
        }
    }
    
}
