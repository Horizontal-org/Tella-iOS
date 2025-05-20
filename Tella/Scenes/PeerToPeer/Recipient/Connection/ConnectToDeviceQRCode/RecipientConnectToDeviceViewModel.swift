//
//  RecipientConnectToDeviceViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/2/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import UIKit
import Combine

enum RecipientConnectToDeviceViewAction {
    case none
    case showToast(message: String)
    case showReceiveFiles
    case showVerificationHash
    case errorOccured // TODO: Update name
    case discardAndStartOver
}

class RecipientConnectToDeviceViewModel: ObservableObject {
    
    var mainAppModel: MainAppModel
    var certificateGenerator : CertificateGenerator
    var server: PeerToPeerServer
    var connectionInfo : ConnectionInfo?
    
    @Published var qrCodeState: ViewModelState<ConnectionInfo> = .loading
    @Published var viewAction: RecipientConnectToDeviceViewAction = .none
    
    private var subscribers : Set<AnyCancellable> = []
    
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
            
            guard let certificateData else {
                self.qrCodeState = .error(LocalizableCommon.commonError.localized)
                return
            }
            
            let clientIdentity = certificateData.identity
            let publicKeyHash = certificateData.publicKeyHash
            
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
        self.server.didRegisterPublisher
            .first()
            .sink { result in
                self.viewAction = result == true ? .showReceiveFiles : .errorOccured
        }.store(in: &subscribers)
    }
}
