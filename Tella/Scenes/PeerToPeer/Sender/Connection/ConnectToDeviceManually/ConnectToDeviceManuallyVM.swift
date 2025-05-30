//
//  ConnectToDeviceManuallyViewModel.swift
//  Tella
//
//  Created by RIMA on 05.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Combine

class ConnectToDeviceManuallyVM: ObservableObject {
    
    var peerToPeerRepository:PeerToPeerRepository
    var sessionId : String?
    var mainAppModel: MainAppModel
    
    @Published var ipAddress : String = ""
    @Published var pin: String = ""
    @Published var port: String = ""
    @Published var publicKey: String = ""
    @Published var valid : Bool = false
    @Published var validFields: Bool = false
    
    // Fields validation
    @Published var isValidIpAddress: Bool = false
    @Published var isValidPin: Bool = false
    @Published var isValidPort : Bool = false
    
    // Fields validation
    @Published var shouldShowIpAddressError: Bool = false
    @Published var shouldShowPinError: Bool = false
    
    @Published var viewState: SenderConnectToDeviceViewAction = .none
    
    private var subscribers = Set<AnyCancellable>()
    var connectionInfo : ConnectionInfo?
    
    init(peerToPeerRepository:PeerToPeerRepository, mainAppModel:MainAppModel) {
        self.peerToPeerRepository = peerToPeerRepository
        self.mainAppModel = mainAppModel
        
        validateFields()
    }
    
    func validateFields() {
        Publishers.CombineLatest3($isValidIpAddress, $isValidPin, $isValidPort)
            .map { ip, pin, port in
                return ip && pin && port
            }
            .assign(to: \.validFields, on: self)
            .store(in: &subscribers)
    }
    
    func getHash() {
        
        guard let port = Int(port) else { return }
        let connectionInfo = ConnectionInfo(ipAddress: ipAddress, port: port, certificateHash: nil, pin: pin)
        self.connectionInfo = connectionInfo
        
        self.peerToPeerRepository.getHash(connectionInfo: connectionInfo)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                debugLog(completion)
                if case .failure = completion {
                    self?.viewState = .showBottomSheetError
                }
            }, receiveValue: { certificateHash in
                debugLog(certificateHash)
                self.connectionInfo?.certificateHash = certificateHash
                self.viewState = .showVerificationHash
            }).store(in: &self.subscribers)
    }
}
