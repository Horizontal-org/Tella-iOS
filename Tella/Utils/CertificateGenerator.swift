//
//  CertificateGenerator.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/2/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation
import X509
import Network

class CertificateGenerator {
    
    private let commonName = "Tella iOS"
    private let organization = "Tella"
    
    // MARK: - Main Function
    
    func generateP12Certificate(ipAddress: String) -> (identity: SecIdentity, publicKeyHash: String)? {
        
        // Generate RSA private key
        guard let privateKey = generateRSAKey() else {
            debugLog("RSA key generation failed")
            return nil
        }
        
        guard let publicKey = privateKey.getPublicKey() else {
            debugLog("Failed to extract public key from private key")
            return nil
        }
        
        // Generate certificate
        guard let certificate = generateSelfSignedCertificate(ipAddress: ipAddress, privateKey: privateKey, publicKey: publicKey) else {
            debugLog("Failed to create certificate")
            return nil
        }
        
        // Store in keychain and return identity
        guard let identity = storeCertificateAndPrivateKey(certificate: certificate, privateKey: privateKey) else {
            debugLog("Failed to store identity")
            return nil
        }
        
        guard let publicKeyData = publicKey.getData() else {
            debugLog("Failed to extract public key data")
            return nil
        }
        
        return (identity, publicKeyData.sha256())
    }
    
    // MARK: - RSA Key Generation
    
    private func generateRSAKey() -> SecKey? {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: false
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            debugLog("RSA key generation error: \(String(describing: error))")
            return nil
        }
        return key
    }
    
    // MARK: - Certificate Generation
    
    private func generateSelfSignedCertificate(ipAddress: String,
                                               privateKey: SecKey,
                                               publicKey: SecKey) -> SecCertificate? {
        do {
            let notBefore = Date()
            let notAfter = notBefore.addYear()
            
            let name = try buildDistinguishedName()
            let sanExtension = try createSANExtension(ipAddress: ipAddress)
            
            var extensions = Certificate.Extensions()
            try extensions.append(sanExtension)
            
            let issuerPrivateKey = try Certificate.PrivateKey(privateKey)
            
            let certificate = try Certificate(
                version: .v3,
                serialNumber: .init(),
                publicKey: issuerPrivateKey.publicKey,
                notValidBefore: notBefore,
                notValidAfter: notAfter!,
                issuer: name,
                subject: name,
                signatureAlgorithm: .sha256WithRSAEncryption,
                extensions: extensions,
                issuerPrivateKey: issuerPrivateKey
            )
            
            return createSecCertificate(from: certificate)
            
        } catch {
            debugLog("Certificate generation failed: \(error)")
            return nil
        }
    }
    
    private func buildDistinguishedName() throws -> DistinguishedName {
        try DistinguishedName {
            CommonName(commonName)
            OrganizationName(organization)
        }
    }
    
    private func createSANExtension(ipAddress: String) throws -> Certificate.Extension {
        
        let ipBytes = try ipAddress.convertIPAddressToBytes()
        let sanValue = createSANExtensionValue(ipBytes: ipBytes)
        
        return Certificate.Extension(
            oid: [2, 5, 29, 17], // Subject Alternative Name
            critical: false,
            value: sanValue[...]
        )
    }
    
    // Helper to create the SAN extension value
    private func createSANExtensionValue(ipBytes: [UInt8]) -> [UInt8] {
        // This creates a minimal SubjectAlternativeName extension containing just the IP address
        // Structure: SEQUENCE -> [7] IMPLICIT OCTET STRING (ipBytes)
        var bytes = [UInt8]()
        
        // Add the IP address (tag 7, context-specific)
        bytes.append(0x87)  // Context-specific tag 7 in constructed form
        bytes.append(UInt8(ipBytes.count))
        bytes.append(contentsOf: ipBytes)
        
        // Wrap in SEQUENCE
        let sequenceLength = bytes.count
        var result = [UInt8]()
        result.append(0x30)  // SEQUENCE tag
        result.append(UInt8(sequenceLength))
        result.append(contentsOf: bytes)
        
        return result
    }
    
    private func createSecCertificate(from certificate: Certificate) -> SecCertificate? {
        do {
            let derData = try certificate.serializeAsPEM().derBytes
            return SecCertificateCreateWithData(nil, Data(derData) as CFData)
        } catch {
            debugLog("DER serialization failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Keychain Storage
    
    private func storeCertificateAndPrivateKey(certificate: SecCertificate, privateKey: SecKey) -> SecIdentity? {
        let tag = "tempkey-\(UUID().uuidString)"
        let tagData = tag.data(using: .utf8)!
        
        let privateKeyAttrs: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tagData,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecValueRef as String: privateKey,
            kSecReturnPersistentRef as String: false
        ]
        
        SecItemDelete(privateKeyAttrs as CFDictionary)
        guard SecItemAdd(privateKeyAttrs as CFDictionary, nil) == errSecSuccess else {
            debugLog("Failed to add private key to Keychain")
            return nil
        }
        
        let certAttrs: [String: Any] = [
            kSecClass as String: kSecClassCertificate,
            kSecValueRef as String: certificate,
            kSecReturnPersistentRef as String: false
        ]
        
        SecItemDelete(certAttrs as CFDictionary)
        guard SecItemAdd(certAttrs as CFDictionary, nil) == errSecSuccess else {
            debugLog("Failed to add certificate to Keychain")
            return nil
        }
        
        let identityQuery: [String: Any] = [
            kSecClass as String: kSecClassIdentity,
            kSecAttrApplicationTag as String: tagData,
            kSecReturnRef as String: true
        ]
        
        var identityRef: CFTypeRef?
        let status = SecItemCopyMatching(identityQuery as CFDictionary, &identityRef)
        
        guard status == errSecSuccess else {
            debugLog("Failed to retrieve identity from Keychain: \(status)")
            return nil
        }
        
        guard let identityRef else {
            debugLog("identityRef is nil")
            return nil
        }
        
        // Convert to CFTypeRef safely
        let identityCF = identityRef as CFTypeRef
        
        guard CFGetTypeID(identityCF) == SecIdentityGetTypeID() else {
            debugLog("Imported item is not a SecIdentity")
            return nil
        }
        
        return (identityCF as! SecIdentity)
    }
}
