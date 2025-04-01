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

class RecipientConnectToDeviceViewModel: ObservableObject {
    
    @Published var qrCodeState: ViewModelState<QRCodeInfos> = .loading
    var mainAppModel: MainAppModel
    
    private var subscribers : Set<AnyCancellable> = []
    var certificateManager : CertificateManager
    var server: PeerToPeerServer
    
    init(certificateManager : CertificateManager, mainAppModel:MainAppModel, server: PeerToPeerServer) {
        self.certificateManager = certificateManager
        self.mainAppModel = mainAppModel
        self.server = server
        
        generateQRCodeInfos()
    }
    
    func generateQRCodeInfos() {
        
        DispatchQueue.main.async {
            let interfaceType = self.mainAppModel.networkMonitor.interfaceTypeValue
            
            guard let ipAddress = UIDevice.current.getIPAddress(for:interfaceType ) else {
                self.qrCodeState = .error("Try to connect to hotspot")
                return
            }
            
            let certificateIsGenerated = self.certificateManager.generateP12Certificate(ipAddress:ipAddress)
            let publicKeyHash = self.certificateManager.getPublicKeyHash()
            
            if certificateIsGenerated, let publicKeyHash {
                let pin = "123456"
                let qrCodeInfos = QRCodeInfos(ipAddress: ipAddress, pin: pin, hash: publicKeyHash)
                self.qrCodeState = .loaded(qrCodeInfos)
                self.server.pin = pin
                self.server.startListening()
            } else {
                self.qrCodeState = .error(LocalizableCommon.commonError.localized)
            }
        }
    }
    
    
}
