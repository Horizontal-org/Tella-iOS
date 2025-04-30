//
//  Cryptor.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import CommonCrypto

// Enum to handle encryption errors
enum CryptoError: Error {
    case cryptorCreationFailed
    case encryptionFailed
    case finalizationFailed
}

class FileCryptor {
    
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
    
    ///  Performes encryption and decryption: creates a cryptographic context, processes the data from the input file and writes it to the provided output file 
    ///  and finally marks the final stage of the encryption or decryption process to the provided output file
    func cryptFile() throws {
        defer {
            inputFile.closeFile()
            outputFile.closeFile()
          
            if let cryptor {
                CCCryptorRelease(cryptor)
            }
        }
        
        try cryptorCreate()
        try cryptorUpdate()
        try cryptorFinal()
    }
    
    /// Creates a cryptographic context that can be used for encryption or decryption operation
    private func cryptorCreate() throws {
        // Setup the encryption context
        let keySize = size_t(kCCKeySizeAES256)
        let algorithm = CCAlgorithm(kCCAlgorithmAES)
        let options = CCOptions(ccNoPadding)
        let mode = CCMode(kCCModeCTR)
        let operation: CCOperation = cryptoOperation == .encrypt ? UInt32(kCCEncrypt) : UInt32(kCCDecrypt)
        
        let operationResult = encryptionKeyData.withUnsafeBytes { keyBytes in
            // CCCryptorCreateWithMode is used for creating a cryptographic context that can be
            // used for encryption or decryption operations with a specified algorithm and mode.
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
        
        guard operationResult ==  kCCSuccess else {
            debugLog("Error encryption \(operationResult)", space: .crypto)
            throw CryptoError.cryptorCreationFailed
        }
    }

    /// It loops through the inputFile and reads the data by buffer. It processes the buffer according to the algorithm and mode defined
    /// in the cryptographic context with CCCryptorUpdate function.
    /// It writes the processed data (encrypted or decrypted) to the provided output file.
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
                        // CCCryptorUpdate is a function for Updating Cryptographic Operations in CommonCrypto (Decryption or Encryption)
                        CCCryptorUpdate(
                            cryptor!,
                            inputBytes.baseAddress, inputBytes.count,
                            outputBytes.baseAddress, outputBytes.count,
                            &encryptedByteCount
                        )
                    }
                }

                guard operationResult == kCCSuccess else {
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
    /// Marks the final stage of the encryption or decryption process to the provided output file
    private func cryptorFinal() throws {
        // Finalize encryption (if any)
        var finalData = Data(count: 0)
        
        var bytesEncrypted = 0
        
        let finalStatus = finalData.withUnsafeMutableBytes { finalData in
            // This function specifically marks the final stage of the encryption or decryption process
            CCCryptorFinal(
                cryptor!,
                finalData.baseAddress, finalData.count,
                &bytesEncrypted
            )
        }
        
        guard finalStatus == kCCSuccess  else {
            debugLog("Error encryption \(finalStatus)", space: .crypto)
            throw CryptoError.finalizationFailed
        }
                
        // Write the final encrypted data to the output file
        try outputFile.write(contentsOf: finalData)
        
    }
    
}
