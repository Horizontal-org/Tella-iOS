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
    var certificateGenerator : CertificateGenerator
    var server: PeerToPeerServer
    
    @Published var qrCodeState: ViewModelState<ConnectionInfo> = .loading
    @Published var viewState: RecipientConnectToDeviceViewState = .none
    
    private var subscribers : Set<AnyCancellable> = []
    let certificateFile = FileManager.tempDirectory(withFileName: "certificate.p12")
    var connectionInfo : ConnectionInfo?
    
    init(certificateGenerator : CertificateGenerator, mainAppModel:MainAppModel, server: PeerToPeerServer) {
        self.certificateGenerator = certificateGenerator
        self.mainAppModel = mainAppModel
        self.server = server
        
        listenToRegisterPublisher()
        generateConnectionInfo()
    }
    
    func generateConnectionInfo() {
        
        DispatchQueue.main.async {
            
            let interfaceType = self.mainAppModel.networkMonitor.interfaceTypeValue
            
            guard let ipAddress = UIDevice.current.getIPAddress(for:interfaceType ) else {
                self.qrCodeState = .error("Try to connect to wifi")
                return
            }
            
            let certificateData = self.certificateGenerator.generateP12Certificate(ipAddress: ipAddress)
            let publicKeyHash = certificateData?.publicKeyData.sha256()
            
            guard let certificateData, let publicKeyHash else {
                self.qrCodeState = .error(LocalizableCommon.commonError.localized)
                return
            }
            
            let clientIdentity = certificateData.identity
            let pin =  "\(Int.random(in: 100000...999999))"
            let port = 53317
            
            let connectionInfo = ConnectionInfo(ipAddress: ipAddress,
                                                port: port,
                                                certificateHash: publicKeyHash,
                                                pin: pin)
            
            self.qrCodeState = .loaded(connectionInfo)
            self.connectionInfo = connectionInfo
            self.server.startListening(port: port, pin: pin, clientIdentity:clientIdentity)
            
        }
    }
    
    func listenToRegisterPublisher() {
        self.server.didRegisterPublisher.sink { value in
            self.viewState = .showReceiveFiles
        }.store(in: &subscribers)
    }
}
