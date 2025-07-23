//
//  RecipientWaitingViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/5/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Combine
import Foundation

enum RecipientPrepareFileTransferAction {
    case showToast(message: String)
    case displayFileTransferView(files: [P2PFile])
    case errorOccured
    case none
}

enum RecipientPrepareFileTransferState {
    case waitingRequest
    case awaitingAcceptance
}

class RecipientPrepareFileTransferVM: ObservableObject {
    
    // MARK: - Properties
    
     var mainAppModel: MainAppModel
     var peerToPeerServer: PeerToPeerServer?
    private var subscribers: Set<AnyCancellable> = []
    private var acceptance: Bool?
    // MARK: - Published Properties
    @Published var viewAction: RecipientPrepareFileTransferAction = .none
    @Published var viewState: RecipientPrepareFileTransferState = .waitingRequest
    @Published var files: [P2PFile] = []
    
    // MARK: - Initializer
    
    init(mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
        self.peerToPeerServer = mainAppModel.peerToPeerServer
        setupListeners()
    }
    
    // MARK: - Setup Methods
    
    private func setupListeners() {
        listenToPrepareUploadPublisher()
        listenToSendPrepareUploadResponsePublisher()
        listenToCloseConnectionPublisher()
    }
    
    // MARK: - Private Methods
    
    private func listenToPrepareUploadPublisher() {
        peerToPeerServer?.didReceivePrepareUploadPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] files in
                guard let self = self else { return }
                self.files = files ?? []
                self.viewState = .awaitingAcceptance
            }
            .store(in: &subscribers)
    }
    
    private func listenToSendPrepareUploadResponsePublisher() {
        peerToPeerServer?.didSendPrepareUploadResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                guard let acceptance else { return }
                
                if acceptance {
                    viewAction = .displayFileTransferView(files: self.files)
                } else {
                    self.viewState = .waitingRequest
                    viewAction = .showToast(message: LocalizablePeerToPeer.recipientFilesRejected.localized)
                }
            }
            .store(in: &subscribers)
    }
    
    private func listenToCloseConnectionPublisher() {
         peerToPeerServer?.didReceiveCloseConnectionPublisher.sink { [weak self] value in
            guard let self = self else { return }
            self.viewAction = .errorOccured
        }.store(in: &subscribers)
    }
    
    // MARK: - Public Methods
    
    func respondToFileUpload(acceptance: Bool) {
        self.acceptance = acceptance
        peerToPeerServer?.prepareUploadPublisher.send(acceptance)
        peerToPeerServer?.prepareUploadPublisher.send(completion: .finished)
    }
    
     func stopServerListening() {
         peerToPeerServer?.stopServer()
    }

}

// MARK: - Preview / Stub

extension RecipientPrepareFileTransferVM {
    static func stub() -> RecipientPrepareFileTransferVM {
        return RecipientPrepareFileTransferVM(
            mainAppModel: MainAppModel.stub()
        )
    }
}


