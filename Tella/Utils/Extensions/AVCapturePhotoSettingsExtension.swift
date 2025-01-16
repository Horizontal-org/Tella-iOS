//
//  AVCapturePhotoSettingsExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 8/1/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import AVFoundation
import CoreLocation


extension AVCapturePhotoSettings {
    
    func add(location:CLLocation) {
        self.metadata[kCGImagePropertyGPSDictionary as String] = createGPSDictionary(location: location)
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

