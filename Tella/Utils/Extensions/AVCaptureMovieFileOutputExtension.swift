//
//  AVCaptureMovieFileOutputExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/6/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import AVFoundation
import CoreLocation

extension AVCaptureMovieFileOutput {
    
    func add(location:CLLocation) {
        // Create metadata item
        let locationMetadataItem = AVMutableMetadataItem()
        locationMetadataItem.identifier = .quickTimeMetadataLocationISO6709
        locationMetadataItem.keySpace = .quickTimeMetadata
        locationMetadataItem.key = AVMetadataKey.quickTimeMetadataKeyLocationISO6709 as (NSCopying & NSObjectProtocol)?
        
        let locationString = convertToISO6709(location: location)
        locationMetadataItem.value = locationString as (NSCopying & NSObjectProtocol)?
        self.metadata = [locationMetadataItem]
    }
    
    func convertToISO6709(location: CLLocation) -> String {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let latitudeString = String(format: "%+08.4f", latitude)
        let longitudeString = String(format: "%+09.4f", longitude)
        
        let iso6709String = "\(latitudeString)\(longitudeString)/"
        return iso6709String
    }
}
