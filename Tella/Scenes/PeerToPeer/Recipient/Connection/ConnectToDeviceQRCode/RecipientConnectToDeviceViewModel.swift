//
//  RecipientConnectToDeviceViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/2/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation
import UIKit
import Combine

enum RecipientConnectToDeviceViewState {
    case none
    case showToast(message: String)
    case showReceiveFiles
}

class RecipientConnectToDeviceViewModel: ObservableObject {
    
    var mainAppModel: MainAppModel
    var certificateManager : CertificateManager
    var server: PeerToPeerServer
    
    @Published var qrCodeState: ViewModelState<ConnectionInfo> = .loading
    @Published var viewState: RecipientConnectToDeviceViewState = .none
    
    private var subscribers : Set<AnyCancellable> = []
    
    init(certificateManager : CertificateManager, mainAppModel:MainAppModel, server: PeerToPeerServer) {
        self.certificateManager = certificateManager
        self.mainAppModel = mainAppModel
        self.server = server
        
        listenToRegisterPublisher()
        generateConnectionInfo()
    }
    
    func generateConnectionInfo() {
        
        DispatchQueue.main.async {
            let interfaceType = self.mainAppModel.networkMonitor.interfaceTypeValue
            
            guard let ipAddress = UIDevice.current.getIPAddress(for:interfaceType ) else {
                self.qrCodeState = .error("Try to connect to hotspot")
                return
            }
            
            let certificateIsGenerated = self.certificateManager.generateP12Certificate(ipAddress:ipAddress)
            let publicKeyHash = self.certificateManager.getPublicKeyHash()
            
            if certificateIsGenerated, let publicKeyHash {
                
                let pin =  "\(Int.random(in: 100000...999999))"
                let port = 53317
                
                let connectionInfo = ConnectionInfo(ipAddress: ipAddress,
                                                    port: port,
                                                    certificateHash: publicKeyHash,
                                                    pin: pin)
                self.qrCodeState = .loaded(connectionInfo)
                self.server.startListening(port: port, pin: pin)
            } else {
                self.qrCodeState = .error(LocalizableCommon.commonError.localized)
            }
        }
    }
    
    func listenToRegisterPublisher() {
        self.server.didRegisterPublisher.sink { value in
            self.viewState = .showReceiveFiles
        }.store(in: &subscribers)
    }
}
