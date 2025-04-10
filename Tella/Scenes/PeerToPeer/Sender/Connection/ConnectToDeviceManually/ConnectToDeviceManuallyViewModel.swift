//
//  ConnectToDeviceManuallyViewModel.swift
//  Tella
//
//  Created by RIMA on 05.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
class ConnectToDeviceManuallyViewModel: ObservableObject {
    
    var cancellables = Set<AnyCancellable>()
    var peerToPeerRepository:PeerToPeerRepository?
    
    init(peerToPeerRepository:PeerToPeerRepository) {
        self.peerToPeerRepository = peerToPeerRepository
        validateFields()
    }
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
    
    func validateFields() {
        Publishers.CombineLatest3($isValidIpAddress, $isValidPin, $isValidPort)
            .map { ip, pin, port in
                return ip && pin && port
            }
            .assign(to: \.validFields, on: self)
            .store(in: &cancellables)
    }
    
    func register() {
        
        let registerRequest = RegisterRequest(pin:pin, nonce: UUID().uuidString )
        guard let port = Int(port) else { return }
        let connectionInfo = ConnectionInfo(ipAddress: ipAddress, port: port, certificateHash: "", pin: pin)
        self.peerToPeerRepository?.register(connectionInfo: connectionInfo)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { response in
                print(response)
            }).store(in: &cancellables)
    }
}
