//
//  RecipientConnectManuallyViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 20/3/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//


import Foundation
import Combine
import UIKit

class RecipientConnectManuallyViewModel: ObservableObject {
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var ipAddress : String = ""
    @Published var pin: String = ""
    @Published var port: String = ""
    private var mainAppModel: MainAppModel?
    private var certificateManager : CertificateManager
    private var server: PeerToPeerServer
    
    init(certificateManager : CertificateManager, mainAppModel:MainAppModel, server: PeerToPeerServer) {
        self.certificateManager = certificateManager
        self.mainAppModel = mainAppModel
        self.server = server
        initParameters()
    }
    
    func initParameters() {
        
        DispatchQueue.main.async {
            let interfaceType = self.mainAppModel?.networkMonitor.interfaceTypeValue
            let port = 53317
            let pin =  Int.random(in: 100000...999999)
            let pinString = "\(pin)"
            let portString = "\(port)"
            
            guard let ipAddress = UIDevice.current.getIPAddress(for:interfaceType ) else {
                return
            }
            
            self.pin = pinString
            self.ipAddress = ipAddress
            self.port = portString
            self.server.startListening(port: port, pin: pinString)
        }
    }
}
