//
//  WifiSSID.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 7/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import CoreLocation
import SystemConfiguration.CaptiveNetwork

class WifiSSID: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    @Published var ssid: String?
    @Published var deniedPermission: Bool = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        checkAuthorizationStatus()
    }
    
    func fetchSSID() {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            loadSSID()
        case .denied, .restricted:
            deniedPermission = true
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func checkAuthorizationStatus() {
        let status = locationManager.authorizationStatus
        if status == .denied || status == .restricted {
            deniedPermission = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.deniedPermission = false
                self.loadSSID()
            case .denied, .restricted:
                self.deniedPermission = true
            default:
                break
            }
        }
    }
    
    private func loadSSID() {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            DispatchQueue.main.async {
                self.ssid = nil
            }
            return
        }
        
        for interface in interfaces {
            guard let networkInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
                  let currentSSID = networkInfo[kCNNetworkInfoKeySSID as String] as? String else {
                continue
            }
            DispatchQueue.main.async {
                self.ssid = currentSSID
            }
            return
        }
        
        DispatchQueue.main.async {
            self.ssid = nil
        }
    }
}
