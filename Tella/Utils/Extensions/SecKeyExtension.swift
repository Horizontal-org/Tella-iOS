//
//  SecKeyExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 15/4/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Security
import Foundation

extension SecKey {
    func getString() -> String? {
        guard let data = getData() else {
            return nil
        }
        return data.base64EncodedString()
    }
    
    func getData() -> Data? {
        var error:Unmanaged<CFError>?
        guard let cfdata = SecKeyCopyExternalRepresentation(self, &error) else {
            return nil
        }
        let data:Data = cfdata as Data
        return data
    }
    
    func getPublicKey() -> SecKey? {
        return SecKeyCopyPublicKey(self)
    }
}

extension SecKey {
    
    var publicKey: SecKey? {
        SecKeyCopyPublicKey(self)
    }
    
    func externalRepresentation(
        errorMessage: String = "Failed to export SecKey"
    ) throws -> Data {
        var error: Unmanaged<CFError>?
        
        guard let data = SecKeyCopyExternalRepresentation(
            self,
            &error
        ) as Data? else {
            throw RuntimeError(
                error?.takeRetainedValue().localizedDescription
                ?? errorMessage
            )
        }
        
        return data
    }
    
    func externalRepresentationOrNil() -> Data? {
        SecKeyCopyExternalRepresentation(self, nil) as Data?
    }
    
    static func makeKey(
        from data: Data,
        options: [String: Any]
    ) -> SecKey? {
        var error: Unmanaged<CFError>?
        
        guard let key = SecKeyCreateWithData(
            data as CFData,
            options as CFDictionary,
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
    
    static func createECPrivateKey() throws -> SecKey {
        var error: Unmanaged<CFError>?
        
        guard let privateKey = SecKeyCreateRandomKey(
            [
                kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeySizeInBits as String: 256
            ] as CFDictionary,
            &error
        ) else {
            throw RuntimeError(
                error?.takeRetainedValue().localizedDescription
                ?? "Failed to create EC private key"
            )
        }
        
        return privateKey
    }
    
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

// MARK: - ECIES

private enum VaultCrypto {

    static let eciesAlgorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM
}

extension SecKey {

    func eciesEncrypt(_ data: Data) -> Data? {
        guard SecKeyIsAlgorithmSupported(self, .encrypt, VaultCrypto.eciesAlgorithm) else {
            debugLog("Algorithm is not supported for encryption", space: .crypto)
            return nil
        }

        var error: Unmanaged<CFError>?

        guard let encryptedData = SecKeyCreateEncryptedData(
            self,
            VaultCrypto.eciesAlgorithm,
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

    func eciesDecrypt(_ data: Data) -> Data? {
        guard SecKeyIsAlgorithmSupported(self, .decrypt, VaultCrypto.eciesAlgorithm) else {
            debugLog("Algorithm is not supported for decryption", space: .crypto)
            return nil
        }

        var error: Unmanaged<CFError>?

        guard let decryptedData = SecKeyCreateDecryptedData(
            self,
            VaultCrypto.eciesAlgorithm,
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
