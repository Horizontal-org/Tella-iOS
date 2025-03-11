//
//  CertificateGenerator.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/2/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation
import OpenSSL
import CommonCrypto

class CertificateGenerator {
    
    /// Generates a P12 certificate (.p12) and a certificate file (.cer).
    ///
    /// - Parameters:
    ///   - commonName: The common name (CN) for the certificate.
    ///   - organization: The organization (O) associated with the certificate.
    ///   - validityDays: The number of days the certificate remains valid.
    ///   - ipAddress: The IP address to be included in the Subject Alternative Name (SAN).
    ///   - p12File: The output file path for the .p12 certificate.
    ///   - cerFile: The output file path for the .cer certificate.
    /// - Returns: `true` if the certificate is successfully generated, otherwise `false`.
    static func generateP12Certificate(
        commonName: String,
        organization: String,
        validityDays: Int,
        ipAddress: String?,
        p12File: String,
        cerFile: String
    ) -> Bool {
        
        // Initialize OpenSSL
        OPENSSL_init_crypto(UInt64(OPENSSL_INIT_ADD_ALL_CIPHERS | OPENSSL_INIT_ADD_ALL_DIGESTS), nil)
        
        // Generate RSA Key Pair
        guard let pkey = generateRSAKey() else {
            debugLog("Error: Failed to generate RSA key.")
            return false
        }
        defer { EVP_PKEY_free(pkey) }
        
        // Create an X.509 Certificate
        guard let x509 = createX509Certificate(pkey: pkey, commonName: commonName, organization: organization, validityDays: validityDays, ipAddress: ipAddress) else {
            debugLog("Error: Failed to create X.509 certificate.")
            return false
        }
        defer { X509_free(x509) }
        
        // Write the certificate to a .cer file
        if !writeCertificate(x509: x509, to: cerFile) {
            debugLog("Error: Failed to write .cer file.")
            return false
        }
        
        // Write the private key and certificate to a .p12 file
        if !writeP12Certificate(x509: x509, pkey: pkey, commonName: commonName, to: p12File) {
            debugLog("Error: Failed to write .p12 file.")
            return false
        }
        
        debugLog("Successfully generated .cer and .p12 certificates with IP address \(ipAddress).")
        return true
    }
    
    // MARK: - Helper Functions
    
    /// Generates a 2048-bit RSA key pair.
    ///
    /// - Returns: The generated EVP_PKEY structure containing the RSA key, or `nil` on failure.
    private static func generateRSAKey() -> OpaquePointer? {
        guard let ctx = EVP_PKEY_CTX_new_id(EVP_PKEY_RSA, nil) else { return nil }
        defer { EVP_PKEY_CTX_free(ctx) }
        
        guard EVP_PKEY_keygen_init(ctx) == 1,
              EVP_PKEY_CTX_set_rsa_keygen_bits(ctx, 2048) == 1 else { return nil }
        
        var pkey: OpaquePointer? = nil
        guard EVP_PKEY_keygen(ctx, &pkey) == 1 else { return nil }
        
        return pkey
    }
    
    /// Creates an X.509 certificate with the specified parameters.
    ///
    /// - Returns: The generated X.509 certificate, or `nil` on failure.
    private static func createX509Certificate(
        pkey: OpaquePointer,
        commonName: String,
        organization: String,
        validityDays: Int,
        ipAddress: String?
    ) -> OpaquePointer? {
        
        guard let x509 = X509_new() else { return nil }
        
        // Set version to X.509 v3
        X509_set_version(x509, 2)
        
        // Set random serial number
        if !setSerialNumber(for: x509) {
            debugLog("Error: Failed to set serial number.")
            return nil
        }
        
        // Set certificate validity period
        let notBefore = X509_getm_notBefore(x509)
        let notAfter = X509_getm_notAfter(x509)
        X509_gmtime_adj(notBefore, 0) // Valid from now
        X509_gmtime_adj(notAfter, Int(validityDays) * 86400) // Validity in seconds
        
        // Set subject name (CN & O)
        X509_set_pubkey(x509, pkey)
        let name = X509_get_subject_name(x509)
        X509_NAME_add_entry_by_txt(name, "CN", MBSTRING_ASC, commonName, -1, -1, 0)
        X509_NAME_add_entry_by_txt(name, "O", MBSTRING_ASC, organization, -1, -1, 0)
        X509_set_issuer_name(x509, name)
        
        // Add Subject Alternative Name (SAN) with IP address
        if !addSubjectAlternativeName(x509: x509, ipAddress: ipAddress) {
            debugLog("Error: Failed to add Subject Alternative Name.")
            return nil
        }
        
        // Sign the certificate with SHA-256
        guard X509_sign(x509, pkey, EVP_sha256()) > 0 else {
            debugLog("Error: Failed to sign certificate.")
            return nil
        }
        debugLog("Certificate successfully created!")
        
        return x509
    }
    
    /// Sets a random serial number for the certificate.
    private static func setSerialNumber(for x509: OpaquePointer) -> Bool {
        guard let serialNumberData = generateSerialNumber(),
              let serialNumberBigInt = BN_bin2bn([UInt8](serialNumberData), Int32(serialNumberData.count), nil),
              let asn1SerialNumber = BN_to_ASN1_INTEGER(serialNumberBigInt, nil) else {
            return false
        }
        
        let success = X509_set_serialNumber(x509, asn1SerialNumber) == 1
        ASN1_INTEGER_free(asn1SerialNumber)
        BN_free(serialNumberBigInt)
        return success
    }
    
    /// Adds a Subject Alternative Name (SAN) with an IP address.
    private static func addSubjectAlternativeName(x509: OpaquePointer, ipAddress: String?) -> Bool {
        var extCtx = X509V3_CTX()
        X509V3_set_ctx(&extCtx, x509, x509, nil, nil, 0)
        guard let ipAddress else {
            debugLog("Error: Failed to add Subject Alternative Name")
            return false
        }
        let sanStr = "IP:\(ipAddress)"
        guard let ext = X509V3_EXT_conf_nid(nil, &extCtx, NID_subject_alt_name, sanStr) else { return false }
        
        let success = X509_add_ext(x509, ext, -1) == 1
        X509_EXTENSION_free(ext)
        return success
    }
    
    /// Writes the X.509 certificate to a `.cer` file.
    private static func writeCertificate(x509: OpaquePointer, to filePath: String) -> Bool {
        guard let file = fopen(filePath, "wb") else { return false }
        defer { fclose(file) }
        
        return i2d_X509_fp(file, x509) != 0
    }
    
    /// Writes the private key and certificate into a `.p12` file.
    private static func writeP12Certificate(x509: OpaquePointer, pkey: OpaquePointer, commonName: String, to filePath: String) -> Bool {
        guard let p12 = PKCS12_create("", commonName, pkey, x509, nil, 0, 0, 0, 0, 0) else { return false }
        defer { PKCS12_free(p12) }
        
        guard let file = fopen(filePath, "wb") else { return false }
        defer { fclose(file) }
        
        return i2d_PKCS12_fp(file, p12) != 0
    }
    
    /// Generates a random 128-bit (16-byte) serial number.
    private static func generateSerialNumber() -> Data? {
        var serialNumber = Data(count: 16)
        serialNumber.withUnsafeMutableBytes { arc4random_buf($0.baseAddress, $0.count) }
        return serialNumber
    }
}
