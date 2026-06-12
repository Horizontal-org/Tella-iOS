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
    case showSenderHashVerification(certificateHash: String)
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
    @Published var scannedSenderCode: String? = nil
    @Published private(set) var didPinSenderCertificate: Bool = false
    @Published var startSenderScanning = PassthroughSubject<Bool, Never>()
    
    // MARK: - Combine
    private var registrationEventsCancellable: AnyCancellable?
    private var networkChangeCancellable: AnyCancellable?
    private var senderScanCancellable: AnyCancellable?
    
    // MARK: - Config
    private let port: Int = 53320
    
    // MARK: - Init
    init(certificateGenerator: CertificateGenerator, mainAppModel: MainAppModel) {
        self.certificateGenerator = certificateGenerator
        self.mainAppModel = mainAppModel
        self.nearbySharingServer = mainAppModel.nearbySharingServer
        
        observeNetworkChanges()
        observeSenderScannedCode()
        generateConnectionInfo()
    }
    
    // MARK: - Observers
    func onAppear() {
        if registrationEventsCancellable == nil {
            listenToServerRegistrationEvents()
        }
        if networkChangeCancellable == nil {
            observeNetworkChanges()
        }
    }
    
    func onDisappear() {
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
    
    private func observeSenderScannedCode() {
        senderScanCancellable = $scannedSenderCode
            .compactMap { $0 }
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] code in
                self?.handleScannedSenderQR(code)
            }
    }
    
    /// Scan sender QR and pin sender certificate hash before any requests.
    private func handleScannedSenderQR(_ code: String) {
        guard let senderInfo = code.decodeJSON(SenderInfo.self) else {
            viewAction = .errorOccured
            return
        }
        nearbySharingServer?.pinSenderCertificateHashFromQR(senderInfo.certificateHash)
        didPinSenderCertificate = true
        viewAction = .showToast(message: LocalizableNearbySharing.senderCertificatePinnedToast.localized)
    }
    
    private func generateConnectionInfo() {
        DispatchQueue.main.async {
            let ipAddresses = UIDevice.current.ipAddresses()
            
            guard !ipAddresses.isEmpty else {
                self.viewAction = .errorOccured
                return
            }
            
            guard let certificateData = self.certificateGenerator.generateP12Certificate(ipAddresses: ipAddresses) else {
                self.viewAction = .errorOccured
                return
            }
            
            let clientIdentity = certificateData.identity
            let certificateHash = certificateData.certificateHash
            let pin = "\(Int.randomSixDigitPIN)"
            
            let connectionInfo = ConnectionInfo(
                ipAddresses: ipAddresses,
                port: self.port,
                certificateHash: certificateHash,
                pin: pin,
                protocolVersion: NearbySharingProtocolVersion.current,
                senderShowHash: false
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
                        // Register accepted immediately.
                        self.viewAction = success ? .showReceiveFiles : .errorOccured
                    }
                    
                case .senderCertificateVerificationRequested(let certificateHash):
                    // Sender hash verification after register.
                    self.viewAction = .showSenderHashVerification(certificateHash: certificateHash)
                    
                case .receiverCertificateVerificationRequested:
                    // Receiver hash verification after ping.
                    self.viewAction = .showVerificationHash
                    
                case .incompatibleProtocolVersion:
                    self.viewAction = .errorOccured
                    
                default:
                    break
                }
            }
    }
}
