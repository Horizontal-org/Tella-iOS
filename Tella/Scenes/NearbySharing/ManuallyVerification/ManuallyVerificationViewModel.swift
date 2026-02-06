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
    case initial
    case waiting
}

class ManuallyVerificationViewModel: ObservableObject {
    
    @Published var senderViewAction: SenderConnectToDeviceViewAction = .none
    @Published var recipientViewAction: RecipientConnectToDeviceViewAction = .none
    
    @Published var shouldEnableConfirmButton: Bool = false
    @Published var confirmButtonTitle: String = ""
    
    private var serverEventsCancellable: AnyCancellable?
    
    var participant: NearbySharingParticipant
    var nearbySharingRepository: NearbySharingRepository?
    var session : NearbySharingSession?
    var connectionInfo: ConnectionInfo
    var mainAppModel: MainAppModel
    var nearbySharingServer: NearbySharingServer?
    
    private var subscribers = Set<AnyCancellable>()
    
    init(participant: NearbySharingParticipant,
         nearbySharingRepository: NearbySharingRepository? = nil,
         connectionInfo: ConnectionInfo,
         mainAppModel: MainAppModel) {
        self.participant = participant
        self.nearbySharingRepository = nearbySharingRepository
        self.connectionInfo = connectionInfo
        self.mainAppModel = mainAppModel
        self.nearbySharingServer = mainAppModel.nearbySharingServer
        
        updateButtonsState(state: .initial)
    }
    
    // MARK: - Observers
    func onAppear() {
        if serverEventsCancellable == nil {
            listenToServerEvents()
        }
    }
    
    func onDisappear() {
        serverEventsCancellable?.cancel()
        serverEventsCancellable = nil
    }

    func updateButtonsState(state: ManuallyVerificationState) {
        
        let result = state == .initial
        
        switch participant {
        case .sender:
            shouldEnableConfirmButton = result
            confirmButtonTitle = result ? LocalizableNearbySharing.verificationConfirm.localized : LocalizableNearbySharing.verificationWaitingRecipient.localized
        case .recipient:
            shouldEnableConfirmButton = result
            confirmButtonTitle = result ? LocalizableNearbySharing.verificationConfirm.localized: LocalizableNearbySharing.verificationWaitingSender.localized
        }
    }
    
    func confirmAction() {
        participant == .recipient ? acceptRegisterRequest() : register()
    }
    
    func discardAction() {
        participant == .recipient ? discardSenderRegisterRequest() : discardRegisterRequest()
    }
    
    private func discardSenderRegisterRequest() {
        self.nearbySharingServer?.respondToRegistrationRequest(accept: false)
        self.nearbySharingServer?.resetServerState()
        recipientViewAction = .discardAndStartOver
    }
    
    private func discardRegisterRequest() {
        senderViewAction = .discardAndStartOver
    }
    
    private func register() {
        
        let registerRequest = RegisterRequest(pin:connectionInfo.pin, nonce: UUID().uuidString )
        self.updateButtonsState(state: .waiting)
        
        self.nearbySharingRepository?.register(connectionInfo: connectionInfo, registerRequest: registerRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.senderViewAction = .showSendFiles
                    self.senderViewAction = .showToast(message: LocalizableNearbySharing.successConnectToast.localized)
                case .failure:
                    self.senderViewAction = .showBottomSheetError
                }
            }, receiveValue: { response in
                if let sessionId = response.sessionId {
                    self.session = NearbySharingSession(sessionId: sessionId)
                }
            }).store(in: &self.subscribers)
    }
    
    private func acceptRegisterRequest() {
        nearbySharingServer?.respondToRegistrationRequest(accept: true)
        self.updateButtonsState(state: .waiting)
    }
    
    func listenToServerEvents() {
        serverEventsCancellable = nearbySharingServer?.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
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
    }
}
