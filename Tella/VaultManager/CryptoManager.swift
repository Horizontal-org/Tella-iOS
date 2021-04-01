//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

/*
This struct provides the necessary functions for key management and data encryption/decryption. Two keypairs are maintained, the meta keypair and the regular keypair. The private meta key is stored in the secure enclave. The public meta key is stored in a file. The regular private key is encrypted using the public meta key and the encrypted result is stored in a file. The regular public key is stored in a file. So, to encrypt files, the regular public key is used.
 To access files, the user is prompted for their authentication when they enter the gallery view. When this authentication is complete, the meta private key is recovered and used to decrypt the regular private key and store the unencrypted private key in memory. Now the user is able to examine their unencrypted files using the regular private key to decrypt.
 */

import Foundation

protocol CryptoManagerInterface {
    func encryptUserData(_ data: Data) -> Data?
    func encrypt(_ data: Data, _ publicKey: SecKey) -> Data?
    func decrypt(_ data: Data, _ privateKey: SecKey) -> Data?
    func encrypt(_ data: Data) -> Data?
    func decrypt(_ data: Data) -> Data?
}

class DummyCryptoManager: CryptoManagerInterface {

    func encryptUserData(_ data: Data) -> Data? {
        return data
    }
    
    func encrypt(_ data: Data) -> Data? {
        return data
    }
    
    func decrypt(_ data: Data) -> Data? {
        return data
    }
    
    func encrypt(_ data: Data, _ publicKey: SecKey) -> Data? {
        return data
    }
    
    func decrypt(_ data: Data, _ privateKey: SecKey) -> Data? {
        return data
    }

}

struct CryptoManager {
    
    private static let metaPrivateKeyTagPrefix = "org.hzontal.tella.ios"
    private static let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM

    private static func metaPrivateKeyTag(_ keyID: String) -> String {
        return "\(metaPrivateKeyTagPrefix).\(keyID)"
    }

    // Query used to recover the meta private key
    private static func metaPrivateKeyQuery(_ keyID: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: metaPrivateKeyTag(keyID),
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
        ]
    }

    @UserDefaultsProperty(key: "keyID")
    private static var keyID: String?
    
    // Returns the options for the given key
    private static func getOptions(_ type: KeyEnum) -> [String: Any] {
        switch (type) {
        case .META_PRIVATE:
            return [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits as String : 256,
                kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave]
        case .PUBLIC:
            return [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits as String : 256]
        case .PRIVATE:
            return [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits as String : 256]
        }
    }
    
    static func metaPrivateKeyExists() -> Bool {
        return recoverMetaPrivateKey() != nil
    }
    
    // Retrieves the meta private key from the secure enclave. Returns nil on failure or if the key doesn't exist yet.
    private static func recoverMetaPrivateKey() -> SecKey? {
        guard let keyID = keyID else { return nil }
        let query = metaPrivateKeyQuery(keyID)
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            print("Error: \(SecCopyErrorMessageString(status, nil) ?? "" as CFString)")
            return nil
        }
        let key = item as! SecKey
        return key
    }
    
    
    // Retrieves a key from a file: meta public, regular public, or regular private.
    // When retrieving the regular private, the user is prompted for their authentication.
    static func recoverKey(_ type: KeyEnum) -> SecKey? {
        guard let keyFileType = type.toKeyFileEnum() else {
            return recoverMetaPrivateKey()
        }
        guard var data = TellaFileManager.recoverKeyData(keyFileType) else {
            print("key not found")
            return nil
        }
        if type == .PRIVATE {
            // Decrypts the regular private key
            guard let metaPrivateKey = recoverKey(.META_PRIVATE) else {
                print("meta private key not recovered")
                return nil
            }
            guard let decryptedData = decrypt(data, metaPrivateKey) else {
                print("data not decrypted")
                return nil
            }
            data = decryptedData
        }
        let options: [String: Any] = getOptions(type)
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(data as CFData, options as CFDictionary, &error) else {
            print("Error: \(error?.takeRetainedValue().localizedDescription ?? "")")
            return nil
        }
        return key
    }

    @discardableResult
    static func deleteMetaKeypair(_ keyID: String) -> Bool {
        let query = metaPrivateKeyQuery(keyID)
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            print("Failed to delete meta private key in enclave")
            return false
        }
        return true
    }
    
    // Generates meta public key from meta private key.
    private static func createMetaPublicKey(_ privateKey: SecKey) throws -> SecKey {
        print("Saving meta public")
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw RuntimeError("Failed to generate meta public key")
        }
        return publicKey
    }
    
    // Retrieves the regular public key, encrypts the regular private key, and saves both.
    private static func saveKeypair(_ privateKey: SecKey, _ metaPrivateKey: SecKey, _ keyID: String) throws {
        var error: Unmanaged<CFError>?
        guard let privateData = SecKeyCopyExternalRepresentation(privateKey, &error) as Data? else {
            let msg = "Error: \(error?.takeRetainedValue().localizedDescription ?? "")"
            throw RuntimeError(msg)
        }
        let metaPublicKey = try createMetaPublicKey(metaPrivateKey)
        guard let privateEncryptedData = encrypt(privateData, metaPublicKey) else {
            throw RuntimeError("Error: Could not encrypt private key")
        }
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw RuntimeError("Failed to generate public key")
        }
        guard let publicData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            let msg = "Error: \(error?.takeRetainedValue().localizedDescription ?? "")"
            throw RuntimeError(msg)
        }
        try TellaFileManager.initKeyFolder(keyID)
        guard TellaFileManager.saveKeyData(privateEncryptedData, .PRIVATE, keyID) else {
            TellaFileManager.deleteKeyFolder(keyID)
            throw RuntimeError("Failed to save encrypted private key")
        }
        guard TellaFileManager.saveKeyData(publicData, .PUBLIC, keyID) else {
            TellaFileManager.deleteKeyFolder(keyID)
            throw RuntimeError("Failed to save public key")
        }
    }
    
    // Generates the meta private key with the appropriate authentication
    private static func createMetaPrivateKey(_ type: PasswordTypeEnum, _ appTag: String) throws -> SecKey {
        // .privateKeyUsage needed so it is accessible
        let access = SecAccessControlCreateWithFlags(
                kCFAllocatorDefault,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                [.privateKeyUsage, type.toFlag()],
                nil)!
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: appTag,
                kSecAttrAccessControl as String: access
            ]
        ]
        var error: Unmanaged<CFError>?
        guard let metaPrivateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            let msg = "Error: \(error?.takeRetainedValue().localizedDescription ?? "")"
            throw RuntimeError(msg)
        }
        return metaPrivateKey
    }
    
    // Generates a new regular private key. Returns nil on failure.
    private static func createPrivateKey() throws -> SecKey {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256
        ]
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("Creating private key failed")
            let msg = "Error: \(error?.takeRetainedValue().localizedDescription ?? "")"
            throw RuntimeError(msg)
        }
        return privateKey
    }
    
    // Checks if both private keys are properly initialized
    static func keysInitialized() -> Bool {
        return metaPrivateKeyExists() && TellaFileManager.keyFileExists(.PRIVATE)
    }
    
    static func initKeys(_ type: PasswordTypeEnum) throws {
        print("Creating all-new keys")
        let privateKey = try createPrivateKey()
        try keyHelper(privateKey, type)
    }
    
    static func updateKeys(_ privateKey: SecKey, _ type: PasswordTypeEnum) throws {
        guard let keyID = keyID else {
            throw RuntimeError("Could not find key ID")
        }
        try keyHelper(privateKey, type)
        deleteMetaKeypair(keyID)
    }
    
    private static func keyHelper(_ privateKey: SecKey, _ type: PasswordTypeEnum) throws {
        let newKeyID = UUID().uuidString
        let newAppTag = metaPrivateKeyTag(newKeyID)
        let metaPrivateKey = try createMetaPrivateKey(type, newAppTag)
        try saveKeypair(privateKey, metaPrivateKey, newKeyID)

        if let keyID = keyID {
            TellaFileManager.deleteKeyFolder(keyID)
        }
        keyID = newKeyID
    }
    
    static func encryptUserData(_ data: Data) -> Data? {
        guard let publicKey = recoverKey(.PUBLIC) else {
            print("Failed to recover public key")
            return nil
        }
        return encrypt(data, publicKey)
    }
    
    // Uses the given public key to encrypt the data. Returns nil on failure.
    private static func encrypt(_ data: Data, _ publicKey: SecKey) -> Data? {
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            print("Algorithm is not supported")
            return nil
        }
        var error: Unmanaged<CFError>?
        guard let cipherText = SecKeyCreateEncryptedData(publicKey, algorithm, data as CFData, &error) as Data? else {
            print("Error: Failed to produce cipher text. \(error!.takeRetainedValue().localizedDescription)")
            return nil
        }
        return cipherText
    }
    
    // Uses the given private key to decrypt the data. Returns nil on failure.
    static func decrypt(_ data: Data, _ privateKey: SecKey) -> Data? {
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
            print("Algorithm is not supported")
            return nil
        }
        var error: Unmanaged<CFError>?
        guard let clearText = SecKeyCreateDecryptedData(privateKey, algorithm, data as CFData, &error) as Data? else {
            print("Decryption failed: \(error!.takeRetainedValue().localizedDescription)")
            return nil
        }
        return clearText
    }
}
