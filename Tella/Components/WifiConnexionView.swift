//
//  WifiConnexionView.swift
//  Tella
//
//  Created by RIMA on 31.01.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct WifiConnexionView: View {
    @StateObject private var viewModel = SSIDViewModel()

    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            ResizableImage("Wifi").frame(width: 43, height: 30)
            Text("Hello, World!")
            if let ssid = viewModel.ssid {
                Text("Connected to: \(ssid)")
                    .font(.title3)
            } else {
                Text("Not connected to Wi-Fi")
                    .foregroundColor(.gray)
            }
            
            // Button to trigger fetch
            Button(action: {
                viewModel.fetchSSID()
            }) {
                Text("Refresh SSID")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $viewModel.showPermissionAlert, content: {
                Text("Please enable location access in Settings to detect the Wi-Fi network.")

                Button("Open Settings") {
                    // Open app settings to enable permissions
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(settingsURL)
                }

            })


        }

        
    }
    var navigationBarView: some View {
        NavigationHeaderView(title: "Wi-Fi",
                             navigationBarType: .inline,
                             backButtonAction: {self.popToRoot()},
                             rightButtonType: .none)

    }

}

#Preview {
    WifiConnexionView()
}


import SwiftUI
import SystemConfiguration.CaptiveNetwork
import CoreLocation

class SSIDViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var ssid: String?
    @Published var showPermissionAlert = false
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // Trigger SSID fetch (checks permissions first)
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
            loadSSID() // Fetch SSID after permission granted
        case .denied, .restricted:
            showPermissionAlert = true // Show alert if denied
        default:
            break
        }
    }
    
    // Fetch SSID using deprecated API (requires entitlements)
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
        ssid = nil // No SSID found
    }
}
