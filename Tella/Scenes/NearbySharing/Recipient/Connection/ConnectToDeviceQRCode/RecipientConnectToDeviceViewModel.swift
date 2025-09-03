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
    
    // MARK: - Dependencies
    var mainAppModel: MainAppModel
    var certificateGenerator: CertificateGenerator
    var nearbySharingServer: NearbySharingServer?
    var connectionInfo: ConnectionInfo?
    
    // MARK: - State
    @Published private(set) var qrCodeState: ViewModelState<UIImage> = .loading
    @Published private(set) var viewAction: RecipientConnectToDeviceViewAction = .none
    
    // MARK: - Combine
    private var registrationEventsCancellable: AnyCancellable?
    private var networkChangeCancellable: AnyCancellable?
    
    // MARK: - Config
    private let port: Int = 53317
    
    // MARK: - Init
    init(certificateGenerator: CertificateGenerator, mainAppModel: MainAppModel) {
        self.certificateGenerator = certificateGenerator
        self.mainAppModel = mainAppModel
        self.nearbySharingServer = mainAppModel.nearbySharingServer
        
        observeNetworkChanges()
        generateConnectionInfo()
    }
    
    // MARK: - Lifecycle Hooks (from View)
    func onAppear() {
        // Re-subscribe if needed
        if registrationEventsCancellable == nil {
            listenToServerRegistrationEvents()
        }
        if networkChangeCancellable == nil {
            observeNetworkChanges()
        }
    }
    
    func onDisappear() {
        // Cancel subscriptions to pause listening
        registrationEventsCancellable?.cancel()
        registrationEventsCancellable = nil
        
        networkChangeCancellable?.cancel()
        networkChangeCancellable = nil
    }
    
    // MARK: - Public Methods
    func stopServerListening() {
        nearbySharingServer?.resetServerState()
    }
    
    // MARK: - Private Methods
    private func observeNetworkChanges() {
        networkChangeCancellable = mainAppModel.networkMonitor.connectionDidChange
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewAction = .showToast(message: LocalizableNearbySharing.connectionChangedToast.localized)
            }
    }
    
    private func generateConnectionInfo() {
        DispatchQueue.main.async {
            let interfaceType = self.mainAppModel.networkMonitor.interfaceTypeValue
            
            guard let ipAddress = UIDevice.current.getIPAddress(for: interfaceType) else {
                self.viewAction = .errorOccured
                return
            }
            
            guard let certificateData = self.certificateGenerator.generateP12Certificate(ipAddress: ipAddress) else {
                self.viewAction = .errorOccured
                return
            }
            
            let clientIdentity = certificateData.identity
            let certificateHash = certificateData.certificateHash
            let pin = "\(Int.randomSixDigitPIN)"
            
            let connectionInfo = ConnectionInfo(
                ipAddress: ipAddress,
                port: self.port,
                certificateHash: certificateHash,
                pin: pin
            )
            
            self.connectionInfo = connectionInfo
            
            self.listenToServerRegistrationEvents()
            self.nearbySharingServer?.startListening(
                port: self.port,
                pin: pin,
                clientIdentity: clientIdentity
            )
        }
    }
    
    private func listenToServerRegistrationEvents() {
        registrationEventsCancellable = nearbySharingServer?.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                
                switch event {
                case .serverStarted:
                    if let connectionInfo = self.connectionInfo {
                        let qrImage = connectionInfo.generateQRCode(size: 215)
                        self.qrCodeState = .loaded(qrImage)
                    }
                    
                case .serverStartFailed:
                    self.viewAction = .errorOccured
                    
                case .didRegister(let success, let manual):
                    if !manual {
                        self.viewAction = success ? .showReceiveFiles : .errorOccured
                    }
                    
                default:
                    break
                }
            }
    }
}
