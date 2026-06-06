//
//  VaultSecKey.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Security

// MARK: - KeyEnum → SecKey

extension KeyEnum {

    func makeSecKey(from data: Data) -> SecKey? {
        var error: Unmanaged<CFError>?

        guard let key = SecKeyCreateWithData(
            data as CFData,
            secKeyAttributes as CFDictionary,
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

    var secKeyAttributes: [String: Any] {
        switch self {
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
}

extension SecKey {

    func externalRepresentationOrThrow(_ errorMessage: String) throws -> Data {
        var error: Unmanaged<CFError>?

        guard let data = SecKeyCopyExternalRepresentation(self, &error) as Data? else {
            throw RuntimeError(
                error?.takeRetainedValue().localizedDescription
                ?? errorMessage
            )
        }

        return data
    }
}
