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
    
    var mainAppModel: MainAppModel
    var peerToPeerRepository: PeerToPeerRepository
    var session: P2PSession?
    
    init(peerToPeerRepository:PeerToPeerRepository, mainAppModel:MainAppModel) {
        self.peerToPeerRepository = peerToPeerRepository
        self.mainAppModel = mainAppModel
        
        super.init()
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
    
    func register(connectionInfo:ConnectionInfo?) {
        
        guard let connectionInfo  else { return }
        
        let registerRequest = RegisterRequest(pin:connectionInfo.pin, nonce: UUID().uuidString)
        
        self.peerToPeerRepository.register(connectionInfo: connectionInfo, registerRequest: registerRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.viewState = .showSendFiles
                    self.viewState = .showToast(message: LocalizablePeerToPeer.successConnectToast.localized)
                case .failure:
                    self.viewState = .showBottomSheetError
                }
            }, receiveValue: { response in
                if let sessionId = response.sessionId {
                    self.session = P2PSession(sessionId: sessionId)
                }
            }).store(in: &self.subscribers)
    }
}
