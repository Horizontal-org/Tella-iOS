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
    case errorOccured
    case discardAndStartOver
}

class RecipientConnectToDeviceViewModel: ObservableObject {
    
    var mainAppModel: MainAppModel
    var certificateGenerator : CertificateGenerator
    var peerToPeerServer: PeerToPeerServer?
    var connectionInfo : ConnectionInfo?
    
    @Published var qrCodeState: ViewModelState<ConnectionInfo> = .loading
    @Published var viewAction: RecipientConnectToDeviceViewAction = .none
    
    private var subscribers : Set<AnyCancellable> = []
    private let port: Int = 53317

    init(certificateGenerator : CertificateGenerator, mainAppModel:MainAppModel) {
        self.certificateGenerator = certificateGenerator
        self.mainAppModel = mainAppModel
        self.peerToPeerServer = mainAppModel.peerToPeerServer
        
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
            let certificateHash = certificateData.certificateHash
            
            let pin = "\(Int.randomSixDigitPIN)"
            
            let connectionInfo = ConnectionInfo(ipAddress: ipAddress,
                                                port: self.port,
                                                certificateHash: certificateHash,
                                                pin: pin)
            
            self.qrCodeState = .loaded(connectionInfo)
            self.connectionInfo = connectionInfo
            self.peerToPeerServer?.startListening(port: self.port, pin: pin, clientIdentity:clientIdentity)
            
            self.peerToPeerServer?.didFailStartServerPublisher.sink { result in
                self.viewAction = .errorOccured
            }.store(in: &self.subscribers)
        }
    }
    
    func listenToRegisterPublisher() {
        peerToPeerServer?.didRegisterPublisher
            .sink { result in
                self.viewAction = result == true ? .showReceiveFiles : .errorOccured
            }.store(in: &subscribers)
    }
    
    func stopServerListening() {
        peerToPeerServer?.stopServer()
    }
    
}
