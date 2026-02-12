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
    case displayFileTransferView(files: [NearbySharingFile])
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
    var nearbySharingServer: NearbySharingServer?
    private var acceptance: Bool?
    private var prepareUploadEventsCancellable: AnyCancellable?

    // MARK: - Published Properties
    @Published var viewAction: RecipientPrepareFileTransferAction = .none
    @Published var viewState: RecipientPrepareFileTransferState = .waitingRequest
    @Published var files: [NearbySharingFile] = []
    
    // MARK: - Initializer
    
    init(mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
        self.nearbySharingServer = mainAppModel.nearbySharingServer
    }
    
    // MARK: - Observers
    func onAppear() {
         if prepareUploadEventsCancellable == nil {
            listenToServerEvents()
        }
    }
    
    func onDisappear() {
        // Cancel subscriptions to pause listening
        prepareUploadEventsCancellable?.cancel()
        prepareUploadEventsCancellable = nil
    }

    // MARK: - Private Methods
    
    private func listenToServerEvents() {
        prepareUploadEventsCancellable = nearbySharingServer?.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                    
                case .prepareUploadReceived(let files):
                    self.files = files ?? []
                    self.viewState = .awaitingAcceptance
                    
                case .prepareUploadResponseSent(let accepted):
                    if accepted {
                        self.viewAction = .displayFileTransferView(files: self.files)
                    } else {
                        self.viewState = .waitingRequest
                        self.viewAction = .showToast(message: LocalizableNearbySharing.recipientFilesRejected.localized)
                    }
                    
                case .connectionClosed, .errorOccured:
                    self.viewAction = .errorOccured
                    
                default:
                    break
                }
            }
    }
    
    // MARK: - Public Methods
    
    func respondToFileUpload(acceptance: Bool) {
        self.acceptance = acceptance
        nearbySharingServer?.respondToFileOffer(accept: acceptance)
    }
    
    func stopServerListening() {
        nearbySharingServer?.resetServerState()
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


