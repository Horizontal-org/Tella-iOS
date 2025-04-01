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
            
            guard let ipAddress = UIDevice.current.getIPAddress(for:interfaceType ) else {
                return
            }
            
            let pin = "123456"
            self.pin = pin
            self.ipAddress = ipAddress
            self.port = "53317"
            self.server.pin = pin
        }
    }
}
