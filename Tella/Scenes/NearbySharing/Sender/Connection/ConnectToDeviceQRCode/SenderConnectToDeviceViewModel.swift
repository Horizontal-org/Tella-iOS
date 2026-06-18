//
//  SenderConnectToDeviceViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/2/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Combine
import UIKit

enum SenderConnectToDeviceViewAction {
    case none
    case showToast(message: String)
    case showBottomSheetError
    case showIncompatibleVersion
    case showSendFiles
    case showRecipientVerificationHash
    case showSenderHashVerification(connectionInfo: ConnectionInfo)
    case discardAndStartOver
}

class SenderConnectToDeviceViewModel: NSObject, ObservableObject {
    
    @Published var scannedCode: String? = nil
    @Published var viewState: SenderConnectToDeviceViewAction = .none
    @Published var startScanning: Bool = true
    @Published var isLoading: Bool = false
    @Published private(set) var qrCodeState: ViewModelState<UIImage> = .loading
    
    private var subscribers = Set<AnyCancellable>()
    private var registrationNonceContext: RegistrationNonceContext?
    
    
    var mainAppModel: MainAppModel
    var nearbySharingRepository: NearbySharingRepository
    var session: NearbySharingSession?
    
    var clientCertificateHash: String? {
        nearbySharingRepository.clientCertificateHash
    }
    
    init(nearbySharingRepository:NearbySharingRepository, mainAppModel:MainAppModel) {
        self.nearbySharingRepository = nearbySharingRepository
        self.mainAppModel = mainAppModel
        nearbySharingRepository.ensureClientTLSIdentity()
        
        super.init()
        generateSenderQRCode()
        observeScannedCode()
    }
    
    private func generateSenderQRCode() {
        guard let hash = clientCertificateHash else {
            qrCodeState = .error(LocalizableCommon.commonError.localized)
            return
        }
        qrCodeState = .loaded(SenderInfo(certificateHash: hash).generateQRCode(size: 215))
    }
    
    func observeScannedCode() {
        scannedCode = nil
        self.$scannedCode
            .compactMap { $0 }
            .prefix(1)
            .sink { [weak self] scannedCode in
                let connectionInfo = scannedCode.decodeJSON(ConnectionInfo.self)
                connectionInfo?.clientTLSIdentity = self?.nearbySharingRepository.clientTLSIdentity
                self?.handleScannedRecipientQR(connectionInfo: connectionInfo)
            }.store(in: &subscribers)
    }
    
    private func handleScannedRecipientQR(connectionInfo: ConnectionInfo?) {
        guard let connectionInfo else {
            viewState = .showBottomSheetError
            return
        }
        
        if connectionInfo.protocolCompatibilityError() != nil {
            viewState = .showIncompatibleVersion
            return
        }
        
        register(connectionInfo: connectionInfo)
        
        if connectionInfo.senderShowHash == true {
            viewState = .showSenderHashVerification(connectionInfo: connectionInfo)
        }
    }
    
    func register(connectionInfo:ConnectionInfo?) {
        guard !isLoading else { return }
        isLoading = true
        
        guard let connectionInfo  else {
            isLoading = false
            return
        }
        
        let nonce = RegistrationNonceContext.nonce(for: connectionInfo, context: &registrationNonceContext)
        let registerRequest = RegisterRequest(pin: connectionInfo.pin,
                                              nonce: nonce)
        
        self.nearbySharingRepository.register(connectionInfo: connectionInfo, registerRequest: registerRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    self?.viewState = .showSendFiles
                    self?.viewState = .showToast(message: LocalizableNearbySharing.successConnectToast.localized)
                case .failure:
                    self?.viewState = .showBottomSheetError
                }
            }, receiveValue: { [weak self] response in
                if let sessionId = response.sessionId {
                    self?.session = NearbySharingSession(sessionId: sessionId)
                    self?.registrationNonceContext = nil
                }
            }).store(in: &self.subscribers)
    }
}
