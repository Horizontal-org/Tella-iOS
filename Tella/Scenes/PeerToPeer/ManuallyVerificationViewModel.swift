//
//  ManuallyVerificationViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 16/4/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class ManuallyVerificationViewModel: ObservableObject {
    
    @Published var viewState: SenderConnectToDeviceViewState = .none
    var participant : PeerToPeerParticipant
    var peerToPeerRepository: PeerToPeerRepository?
    var sessionId : String?
    var connectionInfo:ConnectionInfo
    var mainAppModel:MainAppModel

    private var subscribers = Set<AnyCancellable>()

    init(participant:PeerToPeerParticipant,
         peerToPeerRepository:PeerToPeerRepository? = nil,
         connectionInfo:ConnectionInfo,
         mainAppModel:MainAppModel) {
        self.participant = participant
        self.peerToPeerRepository = peerToPeerRepository
        self.connectionInfo = connectionInfo
        self.mainAppModel = mainAppModel
     }

    func register() {

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
}
