//
//  SSIDViewModel.swift
//  Tella
//
//  Created by RIMA on 03.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI
import SystemConfiguration.CaptiveNetwork
import CoreLocation

class WifiConnetionViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var ssid: String?
    @Published var showPermissionAlert = false
    
    var participent: PeerToPeerParticipent
    
    init(participent: PeerToPeerParticipent) {
        self.participent = participent
        super.init()
        locationManager.delegate = self
        fetchSSID()
    }
    
    private let locationManager = CLLocationManager()

    func fetchSSID() {
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            loadSSID()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // Handle location permission changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            loadSSID()
        case .denied, .restricted:
            showPermissionAlert = true
        default:
            break
        }
    }
    
    private func loadSSID() {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            ssid = nil
            return
        }
        
        for interface in interfaces {
            guard let networkInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
                  let currentSSID = networkInfo[kCNNetworkInfoKeySSID as String] as? String else {
                continue
            }
            ssid = currentSSID
            return
        }
        ssid = nil
    }
}
