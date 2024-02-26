//
//  Cryptor.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import CommonCrypto

// Enum to handle encryption errors
enum CryptoError: Error {
    case cryptorCreationFailed
    case encryptionFailed
    case finalizationFailed
}

class Cryptor {
    
    static let bufferSize = 1024 * 1024 * 8  // 8 MB buffer size
    
    private var cryptor: CCCryptorRef?
    private var cryptoOperation: CryptoOperationEnum
    private var inputFile:FileHandle
    private var outputFile:FileHandle
    private var encryptionKeyData: Data
    
    init(inputFileURL: URL,
         outputFileURL:URL,
         encryptionKeyData: Data,
         cryptoOperation: CryptoOperationEnum) throws {
        
        let _ = inputFileURL.startAccessingSecurityScopedResource()
        defer { inputFileURL.stopAccessingSecurityScopedResource() }
        
        let _ = outputFileURL.startAccessingSecurityScopedResource()
        defer { outputFileURL.stopAccessingSecurityScopedResource() }
        
        // Open the input and output file handles
        self.inputFile = try FileHandle(forReadingFrom: inputFileURL)
        self.outputFile = try FileHandle(forWritingTo: outputFileURL)
        
        self.cryptoOperation = cryptoOperation
        self.encryptionKeyData = encryptionKeyData
    }
    
    func cryptFile() throws {
        try cryptorCreate()
        try cryptorUpdate()
        try cryptorFinal()
    }
    
    private func cryptorCreate() throws  {
        // Setup the encryption context
        let keySize = size_t(kCCKeySizeAES256)
        let algorithm = CCAlgorithm(kCCAlgorithmAES)
        let options = CCOptions(ccNoPadding)
        let mode = CCMode(kCCModeCTR)
        let operation: CCOperation = cryptoOperation == .encrypt ? UInt32(kCCEncrypt) : UInt32(kCCDecrypt)
        
        let operationResult = encryptionKeyData.withUnsafeBytes { keyBytes in
            
            CCCryptorCreateWithMode(
                operation,
                algorithm,
                mode,
                options,
                nil, // Initialization Vector
                keyBytes.baseAddress, // Encryption Key
                keySize,
                nil,
                0,
                0,
                CCModeOptions(kCCModeOptionCTR_BE),
                &cryptor
            )
        }
        
        if operationResult !=  kCCSuccess {
            debugLog("Error encryption \(operationResult)", space: .crypto)
            throw CryptoError.cryptorCreationFailed
        }
    }
    
    private func cryptorUpdate() throws {
        var stop = false
        
        // Process the file in chunks
        while true {
            
            try autoreleasepool {
                
                // Read a chunk from the input file
                
                let inputBuffer = inputFile.readData(ofLength: Self.bufferSize) as Data
                
                var encryptedData = Data(count: Int(Self.bufferSize) + kCCBlockSizeAES128)
                
                if inputBuffer.isEmpty {
                    // Reached end of file
                    stop = true
                }
                
                // Update the encryption context with the input chunk and write the output to the output file
                var encryptedByteCount = 0
                
                let operationResult = inputBuffer.withUnsafeBytes { inputBytes in
                    encryptedData.withUnsafeMutableBytes { outputBytes in
                        CCCryptorUpdate(
                            cryptor!,
                            inputBytes.baseAddress, inputBytes.count,
                            outputBytes.baseAddress, outputBytes.count,
                            &encryptedByteCount
                        )
                    }
                }
                
                if operationResult != kCCSuccess {
                    inputFile.closeFile()
                    outputFile.closeFile()
                    throw CryptoError.encryptionFailed
                }
                
                // Write the encrypted data to the output file
                encryptedData.count = Int(encryptedByteCount)
                try outputFile.write(contentsOf: encryptedData)
            }
            if stop {
                break
            }
        }
    }
    
    private func cryptorFinal() throws {
        // Finalize encryption (if any)
        var finalData = Data(count: 0)
        
        var bytesEncrypted = 0
        
        let finalStatus = finalData.withUnsafeMutableBytes { finalData in
            CCCryptorFinal(
                cryptor!,
                finalData.baseAddress, finalData.count,
                &bytesEncrypted
            )
        }
        
        if finalStatus != kCCSuccess  {
            inputFile.closeFile()
            outputFile.closeFile()
            throw CryptoError.finalizationFailed
        }
        
        CCCryptorRelease(cryptor!)
        
        // Write the final encrypted data to the output file
        try outputFile.write(contentsOf: finalData)
        
    }
    
}
