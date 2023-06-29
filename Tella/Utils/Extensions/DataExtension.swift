//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit
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
}
