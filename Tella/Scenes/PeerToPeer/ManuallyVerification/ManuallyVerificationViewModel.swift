//
//  ManuallyVerificationViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 16/4/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Combine

class ManuallyVerificationViewModel: ObservableObject {
    
    @Published var viewState: SenderConnectToDeviceViewAction = .none
    @Published var shouldShowConfirmButton: Bool = false
    
    var participant : PeerToPeerParticipant
    var peerToPeerRepository: PeerToPeerRepository?
    var sessionId : String?
    var connectionInfo:ConnectionInfo
    var mainAppModel:MainAppModel
    var server:PeerToPeerServer?
    
    private var subscribers = Set<AnyCancellable>()
    
    init(participant:PeerToPeerParticipant,
         peerToPeerRepository:PeerToPeerRepository? = nil,
         connectionInfo:ConnectionInfo,
         mainAppModel:MainAppModel,
         server:PeerToPeerServer? = nil) {
        self.participant = participant
        self.peerToPeerRepository = peerToPeerRepository
        self.connectionInfo = connectionInfo
        self.mainAppModel = mainAppModel
        self.server = server
        shouldShowConfirmButton = participant == .sender
        listenToRequestRegisterPublisher()
    }
    
    func confirmAction() {
        participant == .recipient ? acceptRegisterRequest() : register()
    }
    
    private func register() {
        
        let registerRequest = RegisterRequest(pin:connectionInfo.pin, nonce: UUID().uuidString )
        
        self.peerToPeerRepository?.register(connectionInfo: connectionInfo, registerRequest: registerRequest)
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
    
    private func acceptRegisterRequest() {
        self.server?.acceptRegisterRequest()
    }
    
    private func listenToRequestRegisterPublisher() {
        self.server?.didRequestRegisterPublisher.sink { value in
            self.shouldShowConfirmButton = true
        }.store(in: &subscribers)
    }
}
