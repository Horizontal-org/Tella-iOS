//
//  SecureEnclaveMetaKeyStore.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import LocalAuthentication
import Security

protocol SecureEnclaveMetaKeyStoring: AnyObject {
    func recover(tag: String, password: String) -> SecKey?
    func create(
        passwordType: PasswordTypeEnum,
        tag: String,
        password: String
    ) throws -> SecKey
    @discardableResult
    func delete(tag: String, password: String) -> Bool
    func metaKeyTag(for keyID: String) -> String
}

final class SecureEnclaveMetaKeyStore: SecureEnclaveMetaKeyStoring {

    static let keychainTag = "org.horizontal.tella.ios"

    func metaKeyTag(for keyID: String) -> String {
        "\(Self.keychainTag).\(keyID)"
    }

    func recover(tag: String, password: String) -> SecKey? {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(
            lookupQuery(tag: tag, password: password) as CFDictionary,
            &item
        )

        guard status == errSecSuccess, let item else {
            if status != errSecItemNotFound {
                debugLog(
                    "Failed to recover meta private key for tag \(tag): \(status.securityMessage)",
                    space: .crypto
                )
            }
            return nil
        }

        return secKeyReference(from: item)
    }

    @discardableResult
    func delete(tag: String, password: String) -> Bool {
        let status = SecItemDelete(
            lookupQuery(tag: tag, password: password) as CFDictionary
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

    func create(
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
                ?? "Failed to create meta private key"
            )
        }

        return key
    }
}

// MARK: - Keychain query

private extension SecureEnclaveMetaKeyStore {

    /// Keychain lookup uses `kSecReturnRef` + `kSecClassKey`, so the returned ref is a `SecKey`.
    func secKeyReference(from item: CFTypeRef) -> SecKey {
        item as! SecKey
    }

    func lookupQuery(tag: String, password: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecUseAuthenticationContext as String: authenticationContext(password: password)
        ]
    }

    func authenticationContext(password: String) -> LAContext {
        let context = LAContext()
        context.setCredential(Data(password.utf8), type: .applicationPassword)
        return context
    }
}
