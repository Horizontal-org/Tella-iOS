//
//  CLLocationExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 21/6/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import CoreLocation


extension CLLocation {
    func convertToISO6709() -> String {
        let latitude = self.coordinate.latitude
        let longitude = self.coordinate.longitude
        
        let latitudeString = String(format: "%+08.4f", latitude)
        let longitudeString = String(format: "%+09.4f", longitude)
        
        let iso6709String = "\(latitudeString)\(longitudeString)/"
        return iso6709String
    }
}
