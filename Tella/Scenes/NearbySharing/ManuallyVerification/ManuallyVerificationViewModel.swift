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
    private var registrationNonceContext: RegistrationNonceContext?
    
    var participant: NearbySharingParticipant
    var nearbySharingRepository: NearbySharingRepository?
    var session : NearbySharingSession?
    var connectionInfo: ConnectionInfo
    var mainAppModel: MainAppModel
    var nearbySharingServer: NearbySharingServer?
    var verificationRole: NearbySharingVerificationRole
    var certificateHashToDisplay: String
    
    private var subscribers = Set<AnyCancellable>()
    
    init(participant: NearbySharingParticipant,
         nearbySharingRepository: NearbySharingRepository? = nil,
         connectionInfo: ConnectionInfo,
         mainAppModel: MainAppModel,
         verificationRole: NearbySharingVerificationRole,
         certificateHashToDisplay: String? = nil) {
        self.participant = participant
        self.nearbySharingRepository = nearbySharingRepository
        self.connectionInfo = connectionInfo
        self.mainAppModel = mainAppModel
        self.nearbySharingServer = mainAppModel.nearbySharingServer
        self.verificationRole = verificationRole
        self.certificateHashToDisplay = certificateHashToDisplay
        ?? connectionInfo.certificateHash
        ?? ""
        
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
    
    var stepTitle: String {
        verificationRole.stepTitle(participant: participant)
    }
    
    func updateButtonsState(state: ManuallyVerificationState) {
        let isInitial = state == .initial
        shouldEnableConfirmButton = isInitial
        
        if isInitial {
            confirmButtonTitle = verificationRole.isFinalStep(participant: participant)
            ? LocalizableNearbySharing.verificationConfirm.localized
            : LocalizableNearbySharing.verificationConfirmContinue.localized
        } else {
            confirmButtonTitle = participant == .sender
            ? LocalizableNearbySharing.verificationWaitingRecipient.localized
            : LocalizableNearbySharing.verificationWaitingSender.localized
        }
    }
    
    func confirmAction() {
        switch verificationRole {
        case .receiverHash(let action):
            switch action {
            case .sendRegister:
                if participant == .sender {
                    updateButtonsState(state: .waiting)
                    nearbySharingRepository?.waitForManualPingSenderShowHash()
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { [weak self] completion in
                            guard let self else { return }
                            if case .failure = completion {
                                self.senderViewAction = .showBottomSheetError
                            }
                        }, receiveValue: { [weak self] senderShowHash in
                            guard let self else { return }
                            self.connectionInfo.senderShowHash = senderShowHash
                            self.register()
                            if senderShowHash {
                                self.senderViewAction = .showSenderHashVerification(connectionInfo: self.connectionInfo)
                            }
                        })
                        .store(in: &subscribers)
                } else {
                    acceptRegisterRequest()
                }
            case .acceptPendingRegistration:
                acceptRegisterRequest()
            case .confirmReceiverHash:
                nearbySharingServer?.confirmReceiverHashVerification()
                updateButtonsState(state: .waiting)
            case .acknowledgeOnly:
                updateButtonsState(state: .waiting)
            }
        case .senderHash(let action):
            switch action {
            case .sendRegister:
                register()
            case .acceptPendingRegistration:
                acceptRegisterRequest()
            case .acknowledgeOnly:
                updateButtonsState(state: .waiting)
            case .confirmReceiverHash:
                break
            }
        }
    }
    
    func discardAction() {
        participant == .recipient ? discardSenderRegisterRequest() : discardRegisterRequest()
    }
    
    private func discardSenderRegisterRequest() {
        nearbySharingServer?.discardPendingPing()
        self.nearbySharingServer?.respondToRegistrationRequest(accept: false)
        self.nearbySharingServer?.resetServerState()
        recipientViewAction = .discardAndStartOver
    }
    
    private func discardRegisterRequest() {
        nearbySharingRepository?.cancelManualPing()
        senderViewAction = .discardAndStartOver
    }
    
    private func register() {
        let nonce = RegistrationNonceContext.nonce(for: connectionInfo, context: &registrationNonceContext)
        let registerRequest = RegisterRequest(pin: connectionInfo.pin,
                                              nonce: nonce)
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
            }, receiveValue: { [weak self] response in
                guard let self else { return }
                if let sessionId = response.sessionId {
                    self.session = NearbySharingSession(sessionId: sessionId)
                    self.registrationNonceContext = nil
                }
            }).store(in: &self.subscribers)
    }
    
    private func acceptRegisterRequest() {
        nearbySharingServer?.respondToRegistrationRequest(accept: true)
        updateButtonsState(state: .waiting)
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
                case .senderCertificateVerificationRequested(let certificateHash):
                    // Register held by the server while the recipient is on the receiver hash step:
                    // move to step 2 (sender hash verification)
                    if self.participant == .recipient {
                        self.recipientViewAction = .showSenderHashVerification(certificateHash: certificateHash)
                    }
                case .connectionClosed:
                    self.recipientViewAction = .errorOccured
                default:
                    break
                }
            }
    }
}
