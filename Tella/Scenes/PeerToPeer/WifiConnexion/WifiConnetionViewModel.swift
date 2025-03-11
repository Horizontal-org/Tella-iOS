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
import NetworkExtension
import Combine

class WifiConnetionViewModel: NSObject, ObservableObject {
    @Published var ssid: String? = nil
    @Published var showPermissionAlert = false
    
    var participent: PeerToPeerParticipent
    private var ssidSubscription = Set<AnyCancellable>()
    private var wifiSSID = WifiSSID()
    private var cancellables = Set<AnyCancellable>()
    private var mainAppModel:MainAppModel
    private var interfaceType : NWInterface.InterfaceType?
    
    init(participent: PeerToPeerParticipent, mainAppModel:MainAppModel) {
        
        self.participent = participent
        self.mainAppModel = mainAppModel
        interfaceType = self.mainAppModel.networkMonitor.interfaceTypeValue
        
        super.init()
        
        upadateWifiData()
        listenToConnectionUpdates()
    }
    
    func upadateWifiData() {
        
        interfaceType = self.mainAppModel.networkMonitor.interfaceTypeValue
        switch self.interfaceType {
            
        case .wifi:
            
            wifiSSID.$ssid
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newValue in
                    self?.ssid = newValue
                }.store(in: &ssidSubscription)
            
            wifiSSID.$deniedPermission
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newValue in
                    self?.showPermissionAlert = newValue
                }.store(in: &ssidSubscription)
            
            
            self.wifiSSID.fetchSSID()
            
        case .cellular:
            ssidSubscription.removeAll()
            
            guard let _ = UIDevice.current.getIPAddress(for: .cellular) else {
                self.ssid = nil
                return
            }
            self.ssid = "Hotspot"
            
        default:
            ssidSubscription.removeAll()
            self.ssid = nil
        }
    }
    
    func listenToConnectionUpdates() {
        self.mainAppModel.networkMonitor.interfaceType.sink(receiveValue: { interfaceType in
            if self.interfaceType != interfaceType {
                self.upadateWifiData()
                self.interfaceType = interfaceType
            }
            
        }).store(in: &cancellables)
        
    }
}
