//
//  CertificateGenerator.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/2/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation
import X509
import Crypto
import Network

class CertificateGenerator {
    
    private let commonName = "Tella iOS"
    private let organization = "Tella"
    
    // MARK: - Main Function
    
    func generateP12Certificate(ipAddress:String) -> (identity: SecIdentity, certificateData: Data, privateKeyData: Data, publicKeyData: Data)? {
        // 1. Generate private key
        let privateKey = P256.Signing.PrivateKey()
        let publicKeyData = privateKey.publicKey.x963Representation
        
        // 2. Generate certificate
        guard let certificate = generateSelfSignedCertificate(ipAddress:ipAddress, privateKey: privateKey) else {
            debugLog("Failed to create certificate")
            return nil
        }
        
        // 3. Convert private key to SecKey
        guard let secKey = convertToSecKey(privateKey) else {
            debugLog("Failed to convert private key to SecKey")
            return nil
        }
        
        // 4. Store private key and certificate in the keychain
        guard let identity = storeCertificateAndPrivateKey(certificate: certificate, privateKey: secKey) else {
            debugLog("Failed to store certificate and private key in Keychain")
            return nil
        }
        
        // 5. Return certificate and private key data for possible use
        let certificateData = SecCertificateCopyData(certificate) as Data
        
        guard let cfPrivateKeyData = SecKeyCopyExternalRepresentation(secKey, nil) else {
            debugLog("Failed to extract private key data")
            return nil
        }
        let privateKeyData = cfPrivateKeyData as Data
        
        return (identity, certificateData, privateKeyData, publicKeyData)
    }
    
    // MARK: - Certificate Generation
    
    private func generateSelfSignedCertificate(ipAddress: String,
                                               privateKey: P256.Signing.PrivateKey
    ) -> SecCertificate? {
        do {
            let notBefore = Date()
            let notAfter = notBefore.addYear()
            
            guard let notAfter
            else { return nil }
            
            let publicKey = privateKey.publicKey
            let name = try buildDistinguishedName()
            
            let sanExtension = try createSANExtension(ipAddress: ipAddress)
            
            var extensions = Certificate.Extensions()
            try extensions.append(sanExtension)
            
            let certificate = try Certificate(
                version: .v3,
                serialNumber: .init(),
                publicKey: .init(publicKey),
                notValidBefore: notBefore,
                notValidAfter: notAfter,
                issuer: name,
                subject: name,
                signatureAlgorithm: .ecdsaWithSHA256,
                extensions: extensions,
                issuerPrivateKey: .init(privateKey)
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
    
    // MARK: - Key Conversion
    
    private func convertToSecKey(_ privateKey: P256.Signing.PrivateKey) -> SecKey? {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 256
        ]
        
        var error: Unmanaged<CFError>?
        let x963Data = privateKey.x963Representation
        
        guard let secKey = SecKeyCreateWithData(x963Data as CFData,
                                                attributes as CFDictionary,
                                                &error) else {
            debugLog("Error creating SecKey:")
            return nil
        }
        
        return secKey
    }
    
    // MARK: - Keychain Storage
    
    private func storeCertificateAndPrivateKey(certificate: SecCertificate, privateKey: SecKey) -> SecIdentity? {
        let tag = "org.wearehorizontal.tella.tempkey-\(UUID().uuidString)"
        let tagData = tag.data(using: .utf8)!
        
        // Add private key to Keychain
        let privateKeyAttrs: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tagData,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
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
            kSecReturnPersistentRef as String: true
        ]
        
        SecItemDelete(certAttrs as CFDictionary)
        guard SecItemAdd(certAttrs as CFDictionary, nil) == errSecSuccess else {
            debugLog("Failed to add certificate to Keychain")
            return nil
        }
        
        // Now retrieve the identity
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
