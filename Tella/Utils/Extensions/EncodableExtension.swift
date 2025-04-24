//
//  EncodableExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 8/5/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import UIKit


extension Encodable {
    
    var jsonString: String? {
        if let jsonData = try? JSONEncoder().encode(self), let json = String(bytes: jsonData, encoding: .utf8) {
            return json
        } else {
            return nil
        }
    }
    
    var dictionary: [String: Any] {
        do {
            
            let data = try JSONEncoder().encode(self)
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                return [:]
            }
            return dictionary
        } catch let error as NSError {
            debugLog(error)
            return [:]
        }
    }
    var arraydDictionnary: [[String: Any]] {
        do {
            
            let data = try JSONEncoder().encode(self)
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else {
                return [[:]]
            }
            return dictionary
        } catch let error as NSError {
            debugLog(error)
            return [[:]]
        }
    }
    
    func generateQRCode(size: CGFloat) -> UIImage {
        let data = self.jsonString?.data(using: .utf8)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return UIImage() }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // High error correction
        
        guard let ciImage = filter.outputImage else { return UIImage() }
        
        let transform = CGAffineTransform(scaleX: size / ciImage.extent.width, y: size / ciImage.extent.height)
        let scaledImage = ciImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return UIImage() }
        
        return UIImage(cgImage: cgImage)
    }
    
}
