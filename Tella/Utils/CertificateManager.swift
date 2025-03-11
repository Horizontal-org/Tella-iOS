//
//  CertificateManager.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/3/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//


import Foundation
import UIKit

class CertificateManager {
    
    private let p12File = FileManager.tempDirectory(withFileName: "certificate.p12")
    private let cerFile = FileManager.tempDirectory(withFileName: "certificatee.cer")
    private let commonName = "Tella iOS"
    private let organization = "Tella"
    private let validityDays = 365
    
    // Function to get the public key hash from the certificate
    func getPublicKeyHash() -> String? {
        
        guard let hash = cerFile?.contents()?.getPublicKeyHash() else {
            debugLog("Failed to generate the publicKeyHash")
            return nil
        }
        debugLog("SHA-256 Hash of Public Key: \(hash)")
        return hash
    }
    
    // Function to generate a P12 certificate
    func generateP12Certificate(ipAddress:String? ) -> Bool {
        
        guard let p12FilePath = p12File?.getPath(),
              let cerFilePath = cerFile?.getPath() else {
            return false
        }
        
        let result = CertificateGenerator.generateP12Certificate(commonName: commonName,
                                                                 organization: organization,
                                                                 validityDays: validityDays,
                                                                 ipAddress: ipAddress,
                                                                 p12File: p12FilePath,
                                                                 cerFile: cerFilePath)
        return result
    }
}
