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
    var sessionId : String?
    
    init(peerToPeerRepository:PeerToPeerRepository, mainAppModel:MainAppModel) {
        self.peerToPeerRepository = peerToPeerRepository
        self.mainAppModel = mainAppModel
        
        super.init()
        
        self.$scannedCode
            .compactMap { $0 }
            .prefix(1)
            .sink { [weak self] scannedCode in
                let connectionInfo = scannedCode.decodeJSON(ConnectionInfo.self)
                debugLog(connectionInfo?.certificateHash)
                self?.register(connectionInfo: connectionInfo)
            }.store(in: &subscribers)
    }
    
    func register(connectionInfo:ConnectionInfo?) {
        
        guard let connectionInfo  else { return }

        let registerRequest = RegisterRequest(pin:connectionInfo.pin, nonce: UUID().uuidString )
        
        self.peerToPeerRepository.register(connectionInfo: connectionInfo, registerRequest: registerRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                debugLog(completion)
                switch completion {
                case .finished:
                    self.viewState = .showSendFiles
                    self.viewState = .showToast(message: LocalizablePeerToPeer.successConnectToast.localized)
                case .failure(let error):
                    switch error {
                    case .httpCode(HTTPErrorCodes.unauthorized.rawValue), .badServer:
                        self.viewState = .showBottomSheetError
                    default:
                        debugLog(error)
                        self.viewState = .showToast(message: LocalizablePeerToPeer.serverErrorToast.localized)
                    }
                }
            }, receiveValue: { response in
                debugLog(response)
                self.sessionId = response.sessionId
            }).store(in: &self.subscribers)
    }
}
