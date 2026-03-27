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
    case showSendFiles
    case showVerificationHash
    case discardAndStartOver
}

class SenderConnectToDeviceViewModel: NSObject, ObservableObject {
    
    @Published var scannedCode: String? = nil
    @Published var viewState: SenderConnectToDeviceViewAction = .none
    @Published var startScanning: Bool = true
    
    private var subscribers = Set<AnyCancellable>()
    private var registrationNonceContext: RegistrationNonceContext?

    
    var mainAppModel: MainAppModel
    var nearbySharingRepository: NearbySharingRepository
    var session: NearbySharingSession?
    
    init(nearbySharingRepository:NearbySharingRepository, mainAppModel:MainAppModel) {
        self.nearbySharingRepository = nearbySharingRepository
        self.mainAppModel = mainAppModel
        
        super.init()
        observeNetworkChanges()
        observeScannedCode()
    }
    
    func observeScannedCode() {
        scannedCode = nil
        self.$scannedCode
            .compactMap { $0 }
            .prefix(1)
            .sink { [weak self] scannedCode in
                let connectionInfo = scannedCode.decodeJSON(ConnectionInfo.self)
                self?.register(connectionInfo: connectionInfo)
            }.store(in: &subscribers)
    }
    
    private func observeNetworkChanges() {
        mainAppModel.networkMonitor.connectionDidChange
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewState = .showToast(message: LocalizableNearbySharing.connectionChangedToast.localized)
            }.store(in: &subscribers)
    }
    
    func register(connectionInfo:ConnectionInfo?) {
        
        guard let connectionInfo  else { return }

        let nonce = RegistrationNonceContext.nonce(for: connectionInfo, context: &registrationNonceContext)
        let registerRequest = RegisterRequest(pin: connectionInfo.pin,
                                              nonce: nonce,
                                              senderCertificateHash: "")

        self.nearbySharingRepository.register(connectionInfo: connectionInfo, registerRequest: registerRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.viewState = .showSendFiles
                    self.viewState = .showToast(message: LocalizableNearbySharing.successConnectToast.localized)
                case .failure:
                    self.viewState = .showBottomSheetError
                }
            }, receiveValue: { response in
                if let sessionId = response.sessionId {
                    self.session = NearbySharingSession(sessionId: sessionId)
                    self.registrationNonceContext = nil
                }
            }).store(in: &self.subscribers)
    }
}
