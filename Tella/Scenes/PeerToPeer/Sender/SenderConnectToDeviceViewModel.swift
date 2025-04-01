//
//  SenderConnectToDeviceViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/2/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
import UIKit

class SenderConnectToDeviceViewModel: NSObject, ObservableObject {
    
    @Published var scannedCode: String? = nil
    var subscribers = Set<AnyCancellable>()
    var peerToPeerRepository:PeerToPeerRepository
    
    init(peerToPeerRepository:PeerToPeerRepository) {
        self.peerToPeerRepository = peerToPeerRepository
        super.init()
        
        self.$scannedCode
            .receive(on: DispatchQueue.main)
            .compactMap { $0 } // Unwrap scannedCode
            .first() // Take only the first non-nil value
            .sink { scannedCode in
                let qrCodeInfos = scannedCode.decodeJSON(QRCodeInfos.self)
                self.register(qrCodeInfos: qrCodeInfos)
            }.store(in: &subscribers)    }
    
    func register(qrCodeInfos:QRCodeInfos?) {
        
        guard
            let ipAddress = qrCodeInfos?.ipAddress,
            let hash = qrCodeInfos?.hash,
            let pin = qrCodeInfos?.pin
        else {
            return
        }
        
        let registerRequest = RegisterRequest(pin:pin, nonce: UUID().uuidString )
        
        self.peerToPeerRepository.register(serverURL: ipAddress,
                                           registerRequest: registerRequest,
                                           trustedPublicKeyHash: hash)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            debugLog(completion)
        }, receiveValue: { response in
            debugLog(response)
        }).store(in: &self.subscribers)
    }
}
