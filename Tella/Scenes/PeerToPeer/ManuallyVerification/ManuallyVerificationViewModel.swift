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
    
    @Published var senderViewAction: SenderConnectToDeviceViewAction = .none
    @Published var recipientViewAction: RecipientConnectToDeviceViewAction = .none
    
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
        setupListeners()
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
        self.server?.discardRegisterRequest()
        self.server?.stopListening()
        recipientViewAction = .discardAndStartOver
    }
    
    private func discardRegisterRequest() {
        self.peerToPeerRepository?.closeConnection(closeConnectionRequest:CloseConnectionRequest(sessionID: self.sessionId))
        senderViewAction = .discardAndStartOver
    }
    
    private func register() {
        
        let registerRequest = RegisterRequest(pin:connectionInfo.pin, nonce: UUID().uuidString )
        
        shouldShowConfirmButton = false
        
        self.peerToPeerRepository?.register(connectionInfo: connectionInfo, registerRequest: registerRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                debugLog(completion)
                self.shouldShowConfirmButton = true
                switch completion {
                case .finished:
                    self.senderViewAction = .showSendFiles
                    self.senderViewAction = .showToast(message: LocalizablePeerToPeer.successConnectToast.localized)
                case .failure:
                    self.senderViewAction = .showBottomSheetError
                    /* //TODO: Check scenario
                     switch error {
                     case .httpCode(HTTPErrorCodes.unauthorized.rawValue), .badServer:
                     self.senderViewAction = .showBottomSheetError
                     default:
                     debugLog(error)
                     self.senderViewAction = .showToast(message: LocalizablePeerToPeer.serverErrorToast.localized)
                     }
                     */
                }
            }, receiveValue: { response in
                debugLog(response)
                self.sessionId = response.sessionId
            }).store(in: &self.subscribers)
    }
    
    private func acceptRegisterRequest() {
        self.server?.acceptRegisterRequest()
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
            self.shouldShowConfirmButton = true
        }.store(in: &subscribers)
    }
    
    private func listenToCloseConnectionPublisher() {
        self.server?.didReceiveCloseConnectionPublisher.sink { [weak self] value in
            guard let self = self else { return }
            self.recipientViewAction = .errorOccured
        }.store(in: &subscribers)
    }
}
