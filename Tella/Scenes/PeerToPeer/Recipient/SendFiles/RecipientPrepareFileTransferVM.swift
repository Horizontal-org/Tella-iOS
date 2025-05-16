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
    case none
}

enum RecipientPrepareFileTransferState {
    case waitingRequest
    case awaitingAcceptance
}

class RecipientPrepareFileTransferVM: ObservableObject {
    
    // MARK: - Properties
    
    private var mainAppModel: MainAppModel
    private var server: PeerToPeerServer
    private var subscribers: Set<AnyCancellable> = []
    private var acceptance: Bool?
    // MARK: - Published Properties
    @Published var viewAction: RecipientPrepareFileTransferAction = .none
    @Published var viewState: RecipientPrepareFileTransferState = .waitingRequest
    @Published var files: [P2PFile] = []
    
    // MARK: - Initializer
    
    init(mainAppModel: MainAppModel, server: PeerToPeerServer) {
        self.mainAppModel = mainAppModel
        self.server = server
        setupListeners()
    }
    
    // MARK: - Setup Methods
    
    private func setupListeners() {
        listenToPrepareUploadPublisher()
        listenToSendPrepareUploadResponsePublisher()
        listenToPrepareUploadErrors()
    }
    
    // MARK: - Private Methods
    
    private func listenToPrepareUploadPublisher() {
        server.didReceivePrepareUploadPublisher
            .receive(on: DispatchQueue.main)
            .first()
            .sink { [weak self] files in
                guard let self = self else { return }
                self.files = files
                self.viewState = .awaitingAcceptance
            }
            .store(in: &subscribers)
    }
    
    private func listenToSendPrepareUploadResponsePublisher() {
        server.didSendPrepareUploadResponsePublisher
            .receive(on: DispatchQueue.main)
            .first()
            .sink { [weak self] _ in
                guard let self = self else { return }
                guard let acceptance else { return }
                
                if acceptance {
                    viewAction = .displayFileTransferView(files: self.files)
                } else {
                    viewAction = .showToast(message: LocalizablePeerToPeer.receipientFilesRejected.localized)
                    self.viewState = .waitingRequest
                }
            }
            .store(in: &subscribers)
    }
    
    private func listenToPrepareUploadErrors() {
        server.didReceiveErrorPublisher
            .receive(on: DispatchQueue.main)
            .first()
            .sink { [weak self] _ in
                guard let self = self else { return }
                viewAction = .showToast(message: LocalizableCommon.commonError.localized)
                self.viewState = .waitingRequest
            }
            .store(in: &subscribers)
    }
    
    // MARK: - Public Methods
    
    func respondToFileUpload(acceptance: Bool) {
        self.acceptance = acceptance
        server.sendPrepareUploadFiles(filesAccepted: acceptance)
    }
}

// MARK: - Preview / Stub

extension RecipientPrepareFileTransferVM {
    static func stub() -> RecipientPrepareFileTransferVM {
        return RecipientPrepareFileTransferVM(
            mainAppModel: MainAppModel.stub(),
            server: PeerToPeerServer.stub()
        )
    }
}
