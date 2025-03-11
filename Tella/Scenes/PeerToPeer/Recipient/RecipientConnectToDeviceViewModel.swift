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
    var mainAppModel: MainAppModel?
    
    private var subscribers : Set<AnyCancellable> = []
    private var certificateManager : CertificateManager
    
    init(certificateManager : CertificateManager, mainAppModel:MainAppModel) {
        self.certificateManager = certificateManager
        self.mainAppModel = mainAppModel
        generateQRCodeInfos()
        listenToConnectionChanges()
    }
    
    func listenToConnectionChanges() {
        mainAppModel?.networkMonitor.connectionDidChange.sink(receiveValue: { isConnected in
            self.qrCodeState = .loading
            self.generateQRCodeInfos()
        }).store(in: &subscribers)
    }
    
    func generateQRCodeInfos() {
        
        DispatchQueue.main.async {
            let interfaceType = self.mainAppModel?.networkMonitor.interfaceTypeValue
            
            guard let ipAddress = UIDevice.current.getIPAddress(for:interfaceType ) else {
                self.qrCodeState = .error("Try to connect to hotspot")
                return
            }
            
            let certificateIsGenerated = self.certificateManager.generateP12Certificate(ipAddress:ipAddress)
            let publicKeyHash = self.certificateManager.getPublicKeyHash()
            
            if certificateIsGenerated, let publicKeyHash {
                let qrCodeInfos = QRCodeInfos(ipAddress: ipAddress, pin: "1234", hash: publicKeyHash)
                self.qrCodeState = .loaded(qrCodeInfos)
            } else {
                self.qrCodeState = .error(LocalizableCommon.commonError.localized)
            }
        }
    }
    
    
}
