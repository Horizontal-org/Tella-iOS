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

    func saveEncryptedPrivateKey(_ data: Data, keyID: String) -> Bool
    func recoverEncryptedPrivateKey(keyID: String) -> Data?
    func deleteEncryptedPrivateKey(keyID: String) -> Bool

    func savePublicKey(_ data: Data, keyID: String) -> Bool
    func recoverPublicKey(keyID: String) -> Data?
    func deletePublicKey(keyID: String) -> Bool

    func saveKeyID(_ keyID: String) -> Bool
    func recoverKeyID() -> String?
    func deleteKeyID() -> Bool
}

final class CryptoKeychainStore: CryptoKeychainStoring {

    private enum Constants {
        static let service = "org.horizontal.tella.ios.crypto"
        static let keyIDAccount = "keyID"
    }

    private enum Account {
        static func encryptedPrivateKey(_ keyID: String) -> String {
            "priv-key.\(keyID)"
        }

        static func publicKey(_ keyID: String) -> String {
            "pub-key.\(keyID)"
        }
    }

    func saveEncryptedPrivateKey(_ data: Data, keyID: String) -> Bool {
        save(data, account: Account.encryptedPrivateKey(keyID))
    }

    func recoverEncryptedPrivateKey(keyID: String) -> Data? {
        recover(account: Account.encryptedPrivateKey(keyID))
    }

    func deleteEncryptedPrivateKey(keyID: String) -> Bool {
        delete(account: Account.encryptedPrivateKey(keyID))
    }

    func savePublicKey(_ data: Data, keyID: String) -> Bool {
        save(data, account: Account.publicKey(keyID))
    }

    func recoverPublicKey(keyID: String) -> Data? {
        recover(account: Account.publicKey(keyID))
    }

    func deletePublicKey(keyID: String) -> Bool {
        delete(account: Account.publicKey(keyID))
    }

    func saveKeyID(_ keyID: String) -> Bool {
        save(Data(keyID.utf8), account: Constants.keyIDAccount)
    }

    func recoverKeyID() -> String? {
        guard let data = recover(account: Constants.keyIDAccount) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func deleteKeyID() -> Bool {
        delete(account: Constants.keyIDAccount)
    }
}

// MARK: - Generic Keychain Helpers

private extension CryptoKeychainStore {

    func baseQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: false
        ]
    }

    func save(_ data: Data, account: String) -> Bool {
        let query = baseQuery(account: account)

        let updateAttributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let updateStatus = SecItemUpdate(
            query as CFDictionary,
            updateAttributes as CFDictionary
        )

        if updateStatus == errSecSuccess {
            return true
        }

        guard updateStatus == errSecItemNotFound else {
            debugLog("Keychain update failed: \(updateStatus)", space: .crypto)
            return false
        }

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] =
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let addStatus = SecItemAdd(attributes as CFDictionary, nil)

        if addStatus != errSecSuccess {
            debugLog("Keychain add failed: \(addStatus)", space: .crypto)
        }

        return addStatus == errSecSuccess
    }

    func recover(account: String) -> Data? {
        var query = baseQuery(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            return nil
        }

        return item as? Data
    }

    func delete(account: String) -> Bool {
        let status = SecItemDelete(baseQuery(account: account) as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
