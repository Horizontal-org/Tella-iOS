//
//  CryptoKeychainStore.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 11/5/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Security

protocol CryptoKeychainStoring: AnyObject {
    func saveEncryptedPrivateKey(_ data: Data) -> Bool
    func recoverEncryptedPrivateKey() -> Data?
    func deleteEncryptedPrivateKey() -> Bool
}

protocol SecureEnclaveMetaKeyStoring: AnyObject {
    func recoverMetaPrivateKey(keyID: String?, password: String) -> SecKey?
    func create(
        passwordType: PasswordTypeEnum,
        keyID: String,
        password: String
    ) throws -> SecKey
    @discardableResult
    func delete(keyID: String, password: String) -> Bool
}

typealias VaultKeychainStoring = CryptoKeychainStoring & SecureEnclaveMetaKeyStoring

final class CryptoKeychainStore: VaultKeychainStoring {
    
    private enum Constants {
        static let service = "org.horizontal.tella.ios.crypto"
        static let encryptedPrivateKeyAccount = "priv-key"
        static let keychainTag = "org.horizontal.tella.ios"
    }
    
    private let keychainStore: KeychainStore
    
    init(keychainStore: KeychainStore = KeychainStore()) {
        self.keychainStore = keychainStore
    }
    
    func saveEncryptedPrivateKey(_ data: Data) -> Bool {
        keychainStore.saveGenericPassword(
            data,
            service: Constants.service,
            account: Constants.encryptedPrivateKeyAccount
        )
    }
    
    func recoverEncryptedPrivateKey() -> Data? {
        keychainStore.recoverGenericPassword(
            service: Constants.service,
            account: Constants.encryptedPrivateKeyAccount
        )
    }
    
    func deleteEncryptedPrivateKey() -> Bool {
        keychainStore.deleteGenericPassword(
            service: Constants.service,
            account: Constants.encryptedPrivateKeyAccount
        )
    }
    
    func recoverMetaPrivateKey(
        keyID: String?,
        password: String
    ) -> SecKey? {
        guard !password.isEmpty, let keyID else {
            return nil
        }
        
        return keychainStore.recoverSecureEnclavePrivateKey(
            tag: Self.metaKeyTag(for: keyID),
            password: password
        )
    }
    
    func create(
        passwordType: PasswordTypeEnum,
        keyID: String,
        password: String
    ) throws -> SecKey {
        try keychainStore.createSecureEnclavePrivateKey(
            passwordType: passwordType,
            tag: Self.metaKeyTag(for: keyID),
            password: password
        )
    }
    
    @discardableResult
    func delete(keyID: String, password: String) -> Bool {
        keychainStore.deleteSecureEnclavePrivateKey(
            tag: Self.metaKeyTag(for: keyID),
            password: password
        )
    }
    
    private static func metaKeyTag(for keyID: String) -> String {
        KeychainStore.applicationTag(
            keyID: keyID,
            keychainTag: Constants.keychainTag
        )
    }
}
