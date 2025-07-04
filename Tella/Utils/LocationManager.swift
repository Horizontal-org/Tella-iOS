//
//  LocationManager.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 21/6/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import CoreLocation

class LocationManager : NSObject, CLLocationManagerDelegate {
    
    var currentLocation: CLLocation?
    private var locationManager: CLLocationManager!
    
    
    // MARK: Location Manager
    
    func initializeLocationManager() {
        // Initialize location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopUpdatingLocation() {
        guard let locationManager = self.locationManager else { return  }
        locationManager.stopUpdatingLocation()
    }
    
    // CLLocationManagerDelegate method
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // This is where you do something with your location that's accurate enough.
        guard let userLocation = locations.last else {
            return
        }
        currentLocation = userLocation
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}



