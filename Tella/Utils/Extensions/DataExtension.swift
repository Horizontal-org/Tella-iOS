//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import AVFoundation
import AVKit
import Combine
import CoreLocation

extension Data {
    
    func decoded<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
    
    func string() -> String {
        return String(decoding:  self , as: UTF8.self)
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
}

extension Data {
    
    // Save image with associated location metadata
    func save(withLocation location: CLLocation?, fileURL:URL) -> Bool {
        
        // Create CGImageSource from image data
        guard let source = CGImageSourceCreateWithData(self as CFData, nil) else {
            debugLog("Failed to create CGImageSource.")
            return false
        }
        
        // Get image properties from source
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
            debugLog("Failed to get image properties.")
            return false
        }
        
        // Create mutable dictionary to hold new metadata
        var metadata = imageProperties
        
        // Create CLLocation object from location
        if let location = location {
            metadata[kCGImagePropertyGPSDictionary] = createGPSDictionary(location: location)
        }
        
        // Create CGImageDestination to write the new image with metadata
        let heicUTType = UTType.heic.identifier as CFString
        
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, heicUTType, 1, nil) else {
            debugLog("Failed to create CGImageDestination.")
            return false
        }
        
        // Add the image data with metadata to the destination
        CGImageDestinationAddImageFromSource(destination, source, 0, metadata as CFDictionary)
        
        // Finalize the destination to write the image data with metadata to the URL
        guard CGImageDestinationFinalize(destination) else {
            return false
        }
        return true
    }
    
    // Create GPS dictionary from CLLocation
    func createGPSDictionary(location: CLLocation) -> [CFString: Any] {
        var gpsDict: [CFString: Any] = [:]
        
        // Latitude
        let latitude = location.coordinate.latitude
        gpsDict[kCGImagePropertyGPSLatitude] = abs(latitude)
        gpsDict[kCGImagePropertyGPSLatitudeRef] = latitude >= 0 ? "N" : "S"
        
        // Longitude
        let longitude = location.coordinate.longitude
        gpsDict[kCGImagePropertyGPSLongitude] = abs(longitude)
        gpsDict[kCGImagePropertyGPSLongitudeRef] = longitude >= 0 ? "E" : "W"
        
        // Altitude
        let altitude = location.altitude
        gpsDict[kCGImagePropertyGPSAltitude] = altitude
        gpsDict[kCGImagePropertyGPSAltitudeRef] = altitude >= 0 ? 0 : 1
        
        // Speed
        let speed = location.speed
        if speed >= 0 {
            gpsDict[kCGImagePropertyGPSSpeed] = speed
            gpsDict[kCGImagePropertyGPSSpeedRef] = "K" // Speed in kilometers per hour
        }
        
        // Course (Heading)
        let course = location.course
        if course >= 0 {
            gpsDict[kCGImagePropertyGPSImgDirection] = course
            gpsDict[kCGImagePropertyGPSImgDirectionRef] = "T" // True direction
        }
        
        // Timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd"
        gpsDict[kCGImagePropertyGPSDateStamp] = formatter.string(from: location.timestamp)
        
        formatter.dateFormat = "HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        gpsDict[kCGImagePropertyGPSTimeStamp] = formatter.string(from: location.timestamp)
        
        return gpsDict
    }
}

