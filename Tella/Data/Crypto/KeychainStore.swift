//
//  KeychainStore.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import LocalAuthentication
import Security

final class KeychainStore {

    func saveGenericPassword(_ data: Data, service: String, account: String) -> Bool {
        let query = genericPasswordQuery(service: service, account: account)

        let updateStatus = SecItemUpdate(
            query as CFDictionary,
            [kSecValueData as String: data] as CFDictionary
        )

        if updateStatus == errSecSuccess {
            return true
        }

        guard updateStatus == errSecItemNotFound else {
            debugLog(
                "Keychain update failed for \(account): \(updateStatus.securityMessage)",
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
                "Keychain add failed for \(account): \(addStatus.securityMessage)",
                space: .crypto
            )
        }

        return addStatus == errSecSuccess
    }

    func recoverGenericPassword(service: String, account: String) -> Data? {
        var query = genericPasswordQuery(service: service, account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var itemRef: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &itemRef)

        guard status == errSecSuccess else {
            if status != errSecItemNotFound {
                debugLog(
                    "Keychain recover failed for \(account): \(status.securityMessage)",
                    space: .crypto
                )
            }
            return nil
        }

        return itemRef as? Data
    }

    func deleteGenericPassword(service: String, account: String) -> Bool {
        let status = SecItemDelete(
            genericPasswordQuery(service: service, account: account) as CFDictionary
        )

        if status != errSecSuccess && status != errSecItemNotFound {
            debugLog(
                "Keychain delete failed for \(account): \(status.securityMessage)",
                space: .crypto
            )
            return false
        }

        return true
    }

    func createSecureEnclavePrivateKey(
        passwordType: PasswordTypeEnum,
        tag: String,
        password: String
    ) throws -> SecKey {
        let context = authenticationContext(password: password)

        guard let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage, passwordType.toFlag()],
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
                ?? "Failed to create Secure Enclave private key"
            )
        }

        return key
    }

    func recoverSecureEnclavePrivateKey(tag: String, password: String) -> SecKey? {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(
            secureEnclavePrivateKeyLookupQuery(tag: tag, password: password) as CFDictionary,
            &item
        )

        guard status == errSecSuccess, let item else {
            if status != errSecItemNotFound {
                debugLog(
                    "Failed to recover Secure Enclave private key for tag \(tag): \(status.securityMessage)",
                    space: .crypto
                )
            }
            return nil
        }

        return item as! SecKey
    }

    @discardableResult
    func deleteSecureEnclavePrivateKey(tag: String, password: String) -> Bool {
        let status = SecItemDelete(
            secureEnclavePrivateKeyLookupQuery(tag: tag, password: password) as CFDictionary
        )

        guard status == errSecSuccess || status == errSecItemNotFound else {
            debugLog(
                "Failed to delete Secure Enclave private key for tag \(tag): \(status.securityMessage)",
                space: .crypto
            )
            return false
        }

        return true
    }

    static func applicationTag(keyID: String, keychainTag: String) -> String {
        "\(keychainTag).\(keyID)"
    }

    private func genericPasswordQuery(service: String, account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: false,
            kSecUseDataProtectionKeychain as String: true
        ]
    }

    private func secureEnclavePrivateKeyLookupQuery(tag: String, password: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecUseAuthenticationContext as String: authenticationContext(password: password)
        ]
    }

    private func authenticationContext(password: String) -> LAContext {
        let context = LAContext()
        context.setCredential(Data(password.utf8), type: .applicationPassword)
        return context
    }
}
