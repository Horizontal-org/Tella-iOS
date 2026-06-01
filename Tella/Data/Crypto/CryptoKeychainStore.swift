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

    func savePublicKey(_ data: Data) -> Bool
    func recoverPublicKey() -> Data?
    func deletePublicKey() -> Bool

    func deleteVaultKeyMaterial() -> Bool
}

final class CryptoKeychainStore: CryptoKeychainStoring {

    private enum Constants {
        static let service = "org.horizontal.tella.ios.crypto"
        static let encryptedPrivateKeyAccount = "priv-key"
        static let publicKeyAccount = "pub-key"
    }

    private enum KeychainItem {
        case encryptedPrivateKey
        case publicKey

        var account: String {
            switch self {
            case .encryptedPrivateKey:
                return Constants.encryptedPrivateKeyAccount

            case .publicKey:
                return Constants.publicKeyAccount
            }
        }
    }

    func saveEncryptedPrivateKey(_ data: Data) -> Bool {
        save(data, item: .encryptedPrivateKey)
    }

    func recoverEncryptedPrivateKey() -> Data? {
        recover(item: .encryptedPrivateKey)
    }

    func deleteEncryptedPrivateKey() -> Bool {
        delete(item: .encryptedPrivateKey)
    }

    func savePublicKey(_ data: Data) -> Bool {
        save(data, item: .publicKey)
    }

    func recoverPublicKey() -> Data? {
        recover(item: .publicKey)
    }

    func deletePublicKey() -> Bool {
        delete(item: .publicKey)
    }

    func deleteVaultKeyMaterial() -> Bool {
        let privateKeyDeleted = deleteEncryptedPrivateKey()
        let publicKeyDeleted = deletePublicKey()
        return privateKeyDeleted && publicKeyDeleted
    }
}

// MARK: - Keychain Helpers

private extension CryptoKeychainStore {

    private func baseQuery(for item: KeychainItem) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.service,
            kSecAttrAccount as String: item.account,
            kSecAttrSynchronizable as String: false,
            kSecUseDataProtectionKeychain as String: true
        ]
    }

    private func save(_ data: Data, item: KeychainItem) -> Bool {
        let query = baseQuery(for: item)

        let updateStatus = SecItemUpdate(
            query as CFDictionary,
            [kSecValueData as String: data] as CFDictionary
        )

        if updateStatus == errSecSuccess {
            return true
        }

        guard updateStatus == errSecItemNotFound else {
            debugLog(
                "Keychain update failed for \(item.account): \(updateStatus.securityMessage)",
                space: .crypto
            )
            return false
        }

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] =
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let addStatus = SecItemAdd(attributes as CFDictionary, nil)

        if addStatus != errSecSuccess {
            debugLog(
                "Keychain add failed for \(item.account): \(addStatus.securityMessage)",
                space: .crypto
            )
        }

        return addStatus == errSecSuccess
    }

    private func recover(item: KeychainItem) -> Data? {
        var query = baseQuery(for: item)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var itemRef: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &itemRef)

        guard status == errSecSuccess else {
            if status != errSecItemNotFound {
                debugLog(
                    "Keychain recover failed for \(item.account): \(status.securityMessage)",
                    space: .crypto
                )
            }
            return nil
        }

        return itemRef as? Data
    }

    private func delete(item: KeychainItem) -> Bool {
        let status = SecItemDelete(baseQuery(for: item) as CFDictionary)

        if status != errSecSuccess && status != errSecItemNotFound {
            debugLog(
                "Keychain delete failed for \(item.account): \(status.securityMessage)",
                space: .crypto
            )
            return false
        }

        return true
    }
}

// MARK: - OSStatus Helper

private extension OSStatus {

    var securityMessage: String {
        SecCopyErrorMessageString(self, nil) as String? ?? "\(self)"
    }
}
