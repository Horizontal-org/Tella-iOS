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
    
    @Published var viewState: SenderConnectToDeviceViewState = .none
    
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
    
    func register() {
        
        let registerRequest = RegisterRequest(pin:pin, nonce: UUID().uuidString )
        guard let port = Int(port) else { return }
        let connectionInfo = ConnectionInfo(ipAddress: ipAddress, port: port, certificateHash: nil, pin: pin)
        self.connectionInfo = connectionInfo
        
        self.peerToPeerRepository.register(connectionInfo: connectionInfo, registerRequest: registerRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                debugLog(completion)
                
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    switch error {
                    case .httpCode(HTTPErrorCodes.unauthorized.rawValue), .badServer:
                        self.viewState = .showBottomSheetError
                        
                    case .cancelAuthenticationChallenge(let certificateHash):
                        connectionInfo.certificateHash = certificateHash
                        self.viewState = .showVerificationHash
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
