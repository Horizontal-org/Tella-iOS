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

final class LocationManager: NSObject {
    enum AuthorizationState: Equatable {
        case notDetermined
        case authorized
        case denied
    }
    
    private(set) var currentLocation: CLLocation?
    weak var observer: LocationManagerObserver?
    
    private let locationManager = CLLocationManager()
    private var shouldMonitorLocation = false
    private var isMonitoringLocation = false
    
    private var authorizationState: AuthorizationState {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .authorizedWhenInUse, .authorizedAlways:
            return .authorized
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    // MARK: - Location updates
    
    func startUpdatingLocation() {
        shouldMonitorLocation = true
        applyAuthorizationStatus()
    }
    
    func stopUpdatingLocation() {
        shouldMonitorLocation = false
        stopMonitoringLocation()
    }
    
    private func applyAuthorizationStatus() {
        let authorizationState = authorizationState
        
        switch authorizationState {
        case .notDetermined:
            if shouldMonitorLocation {
                locationManager.requestWhenInUseAuthorization()
            }
        case .authorized:
            startMonitoringLocationIfNeeded()
        case .denied:
            currentLocation = nil
            stopMonitoringLocation()
        }
        
        if shouldMonitorLocation {
            observer?.locationManager(self, didChangeAuthorization: authorizationState)
        }
    }
    
    private func startMonitoringLocationIfNeeded() {
        guard shouldMonitorLocation, !isMonitoringLocation else { return }
        
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.startMonitoringSignificantLocationChanges()
        } else {
            locationManager.startUpdatingLocation()
        }
        
        isMonitoringLocation = true
    }
    
    private func stopMonitoringLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        isMonitoringLocation = false
    }
}

protocol LocationManagerObserver: AnyObject {
    func locationManager(_ manager: LocationManager, didUpdate location: CLLocation)
    func locationManager(_ manager: LocationManager,
                         didChangeAuthorization authorizationState: LocationManager.AuthorizationState)
    func locationManager(_ manager: LocationManager, didFailWithError error: Error)
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last(where: { $0.horizontalAccuracy >= 0 }) else { return }
        currentLocation = location
        observer?.locationManager(self, didUpdate: location)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        applyAuthorizationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        observer?.locationManager(self, didFailWithError: error)
    }
}
