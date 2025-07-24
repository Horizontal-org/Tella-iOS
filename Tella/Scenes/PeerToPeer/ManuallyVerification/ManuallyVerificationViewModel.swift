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
enum ManuallyVerificationState {
    case waitingForSenderResponse
    case waitingForRecipientResponse
}
                                    
class ManuallyVerificationViewModel: ObservableObject {
    
    @Published var senderViewAction: SenderConnectToDeviceViewAction = .none
    @Published var recipientViewAction: RecipientConnectToDeviceViewAction = .none
    
    @Published var shouldEnableConfirmButton: Bool = false
    @Published var confirmButtonTitle: String = ""

    var participant : PeerToPeerParticipant
    var peerToPeerRepository: PeerToPeerRepository?
    var session : P2PSession?
    var connectionInfo:ConnectionInfo
    var mainAppModel:MainAppModel
    var peerToPeerServer:PeerToPeerServer?
    
    private var subscribers = Set<AnyCancellable>()
    
    init(participant:PeerToPeerParticipant,
         peerToPeerRepository:PeerToPeerRepository? = nil,
         connectionInfo:ConnectionInfo,
         mainAppModel:MainAppModel) {
        self.participant = participant
        self.peerToPeerRepository = peerToPeerRepository
        self.connectionInfo = connectionInfo
        self.mainAppModel = mainAppModel
        self.peerToPeerServer = mainAppModel.peerToPeerServer
        
        updateButtonsState(state: .waitingForSenderResponse)
        
        listenToServerEvents()
    }
    
    func updateButtonsState(state: ManuallyVerificationState) {
        
        let result = state == .waitingForSenderResponse

        switch participant {
        case .sender:
             shouldEnableConfirmButton = result
            confirmButtonTitle = result ? LocalizablePeerToPeer.verificationConfirm.localized : LocalizablePeerToPeer.verificationWaitingRecipient.localized
        case .recipient:
            shouldEnableConfirmButton = !result
            confirmButtonTitle = result ? LocalizablePeerToPeer.verificationWaitingSender.localized : LocalizablePeerToPeer.verificationConfirm.localized
        }
    }

    func confirmAction() {
        participant == .recipient ? acceptRegisterRequest() : register()
    }
    
    func discardAction() {
        participant == .recipient ? discardSenderRegisterRequest() : discardRegisterRequest()
    }
    
    private func discardSenderRegisterRequest() {
        self.peerToPeerServer?.respondToRegistrationRequest(accept: false)
        self.peerToPeerServer?.resetServer()
        recipientViewAction = .discardAndStartOver
    }
    
    private func discardRegisterRequest() {
        senderViewAction = .discardAndStartOver
    }
    
    private func register() {
        
        let registerRequest = RegisterRequest(pin:connectionInfo.pin, nonce: UUID().uuidString )
        self.updateButtonsState(state: .waitingForRecipientResponse)

        self.peerToPeerRepository?.register(connectionInfo: connectionInfo, registerRequest: registerRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                updateButtonsState(state: ManuallyVerificationState.waitingForSenderResponse)
                switch completion {
                case .finished:
                    self.senderViewAction = .showSendFiles
                    self.senderViewAction = .showToast(message: LocalizablePeerToPeer.successConnectToast.localized)
                case .failure:
                    self.senderViewAction = .showBottomSheetError
                }
            }, receiveValue: { response in
                if let sessionId = response.sessionId {
                    self.session = P2PSession(sessionId: sessionId)
                }
            }).store(in: &self.subscribers)
    }

    private func acceptRegisterRequest() {

        peerToPeerServer?.respondToRegistrationRequest(accept: true)
      
    }

    func listenToServerEvents() {
        peerToPeerServer?.eventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }

                switch event {
                case .registrationRequested:
                    self.updateButtonsState(state: .waitingForRecipientResponse)

                case .didRegister(let success, let manual):
                    if manual {
                        self.recipientViewAction = success ? .showReceiveFiles : .errorOccured
                    }

                case .connectionClosed:
                    self.recipientViewAction = .errorOccured

                default:
                    break
                }
            }
            .store(in: &subscribers)
    }

}
