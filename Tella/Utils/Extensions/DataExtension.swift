//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import AVFoundation
import AVKit
import Combine
import CoreLocation
import CommonCrypto

extension Data {
    
    func decoded<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
    
    func string() -> String {
        return String(decoding:  self , as: UTF8.self)
    }

    /// Strict UTF-8 decoding — returns nil if data is invalid
    func utf8String() -> String? {
        return String(data: self, encoding: .utf8)
    }

    mutating func extract(size: Int?) -> Data? {
        
        guard let size,  self.count > size  else {
            return nil
        }
        
        // Define the length of data to return
        // Create a range based on the length of data to return
        let range = (0..<size)
        
        // Get a new copy of data
        // let subData = self.subdata(in: range)
        
        // Mutate data
        self.removeSubrange(range)
        
        // Return the new copy of data
        return self
    }

    /// This function takes the image data and metadata as parameter and returns the image data with metadata
    /// - Parameters:
    ///   - data: The original image data
    ///   - properties: The metadata that is need to be written to the image data
    /// - Returns: The image data with metadata
    func saveImageWithImageData(properties: NSDictionary) async -> NSData {
        let imageRef: CGImageSource = CGImageSourceCreateWithData((self as CFData), nil)!
        let uti: CFString = CGImageSourceGetType(imageRef)!
        let dataWithEXIF: NSMutableData = NSMutableData(data: self)
        let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableData), uti, 1, nil)!

        CGImageDestinationAddImageFromSource(destination, imageRef, 0, (properties as CFDictionary))
        CGImageDestinationFinalize(destination)
        return dataWithEXIF
    }
    
    func byRemovingEXIF() -> Data? {
        guard let source = CGImageSourceCreateWithData(self as NSData, nil),
              let type = CGImageSourceGetType(source) else
        {
            return nil
        }

        let count = CGImageSourceGetCount(source)
        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(mutableData, type, count, nil) else {
            return nil
        }

        let exifToRemove: CFDictionary = [
            kCGImagePropertyExifDictionary: kCFNull,
            kCGImagePropertyGPSDictionary: kCFNull,
            kCGImagePropertyTIFFDictionary : kCFNull
        ] as CFDictionary

        for index in 0 ..< count {
            CGImageDestinationAddImageFromSource(destination, source, index, exifToRemove)
            if !CGImageDestinationFinalize(destination) {
                debugLog("Failed to finalize")
            }
        }

        return mutableData as Data
    }

    
    func fileExtension(vaultManager:VaultManager) -> String? {
        let fileTypeHelper = FileTypeHelper(data: self).getFileInformation()
        return fileTypeHelper?.fileExtension
    }
    
    // Function to compute SHA-256 hash
    func sha256() -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
}
