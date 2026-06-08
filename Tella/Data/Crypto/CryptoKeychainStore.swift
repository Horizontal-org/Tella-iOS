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

final class CryptoKeychainStore: CryptoKeychainStoring {
    
    private enum Constants {
        static let service = "org.horizontal.tella.ios.crypto"
        static let encryptedPrivateKeyAccount = "priv-key"
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.service,
            kSecAttrAccount as String: Constants.encryptedPrivateKeyAccount,
            kSecAttrSynchronizable as String: false,
            kSecUseDataProtectionKeychain as String: true
        ]
    }

    func saveEncryptedPrivateKey(_ data: Data) -> Bool {
        let query = baseQuery
        
        let updateStatus = SecItemUpdate(
            query as CFDictionary,
            [kSecValueData as String: data] as CFDictionary
        )
        
        if updateStatus == errSecSuccess {
            return true
        }
        
        guard updateStatus == errSecItemNotFound else {
            debugLog(
                "Keychain update failed for \(Constants.encryptedPrivateKeyAccount): \(updateStatus.securityMessage)",
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
                "Keychain add failed for \(Constants.encryptedPrivateKeyAccount): \(addStatus.securityMessage)",
                space: .crypto
            )
        }
        
        return addStatus == errSecSuccess
    }
    
    func recoverEncryptedPrivateKey() -> Data? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var itemRef: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &itemRef)
        
        guard status == errSecSuccess else {
            if status != errSecItemNotFound {
                debugLog(
                    "Keychain recover failed for \(Constants.encryptedPrivateKeyAccount): \(status.securityMessage)",
                    space: .crypto
                )
            }
            return nil
        }
        
        return itemRef as? Data
    }
    
    func deleteEncryptedPrivateKey() -> Bool {
        let status = SecItemDelete(baseQuery as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            debugLog(
                "Keychain delete failed for \(Constants.encryptedPrivateKeyAccount): \(status.securityMessage)",
                space: .crypto
            )
            return false
        }
        
        return true
    }
}
