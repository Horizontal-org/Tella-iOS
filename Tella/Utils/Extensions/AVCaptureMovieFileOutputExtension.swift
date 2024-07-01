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
        
        let locationString = location.convertToISO6709()
        locationMetadataItem.value = locationString as (NSCopying & NSObjectProtocol)?
        self.metadata = [locationMetadataItem]
    }
}
