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
        
        updateButtonsState(state: .waitingForSenderResponse)
        
        setupListeners()
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
    
    // MARK: - Setup Methods
    
    private func setupListeners() {
        listenToRequestRegisterPublisher()
        listenToRegisterPublisher()
        listenToCloseConnectionPublisher()
    }
    
    func confirmAction() {
        participant == .recipient ? acceptRegisterRequest() : register()
    }
    
    func discardAction() {
        participant == .recipient ? discardSenderRegisterRequest() : discardRegisterRequest()
    }
    
    private func discardSenderRegisterRequest() {
        self.server?.discardRegisterPublisher.send(completion: .finished)
        self.server?.stopServer()
        recipientViewAction = .discardAndStartOver
    }
    
    private func discardRegisterRequest() {
        self.peerToPeerRepository?.closeConnection(closeConnectionRequest:CloseConnectionRequest(sessionID: self.session?.sessionId))
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
        self.server?.acceptRegisterPublisher.send(completion: .finished)
    }
    
    func listenToRegisterPublisher() {
        self.server?.didRegisterManuallyPublisher
            .sink { [weak self] result in
                guard let self = self else { return }
                self.recipientViewAction = result == true ? .showReceiveFiles : .errorOccured
            }.store(in: &subscribers)
    }

    private func listenToRequestRegisterPublisher() {
        self.server?.didRequestRegisterPublisher.sink { [weak self] value in
            guard let self = self else { return }
            self.updateButtonsState(state: .waitingForRecipientResponse)
        }.store(in: &subscribers)
    }
    
    private func listenToCloseConnectionPublisher() {
        self.server?.didReceiveCloseConnectionPublisher.sink { [weak self] value in
            guard let self = self else { return }
            self.recipientViewAction = .errorOccured
        }.store(in: &subscribers)
    }
}
