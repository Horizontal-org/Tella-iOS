//
//  P2PSendFilesViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/4/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Combine
import Foundation

enum SenderPrepareFileTransferAction {
    case showToast(message: String)
    case displaySendingFiles
    case errorOccured
    case none
}

enum SenderPrepareFileTransferState {
    case waiting
    case prepareFiles
}

class SenderPrepareFileTransferVM: ObservableObject {
    
    var mainAppModel: MainAppModel
    var sessionId : String?
    var peerToPeerRepository: PeerToPeerRepository
    
    //MARK: -AddFilesViewModel
    @Published var addFilesViewModel: AddFilesViewModel
    @Published var title: String = ""
    @Published var validTitle: Bool = false
    
    @Published var viewAction: SenderPrepareFileTransferAction = .none
    @Published var viewState: SenderPrepareFileTransferState = .prepareFiles
    @Published var reportIsValid : Bool = false
    
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel: MainAppModel, sessionId : String, peerToPeerRepository: PeerToPeerRepository) {
        self.mainAppModel = mainAppModel
        self.addFilesViewModel = AddFilesViewModel(mainAppModel: mainAppModel)
        self.sessionId = sessionId
        self.peerToPeerRepository = peerToPeerRepository
        validateReport()
    }
    
    func validateReport() {
        Publishers.CombineLatest($validTitle, addFilesViewModel.$files)
            .map { validTitle, files in
                (validTitle && !files.isEmpty)
            }
            .assign(to: \.reportIsValid, on: self)
            .store(in: &subscribers)
    }
    
    func prepareUpload() {
        self.viewState = .waiting
        
        guard let sessionId else { return }
        
        let files = addFilesViewModel.files.compactMap { file in
            return P2PFile(id: UUID().uuidString,
                           fileName: file.name,
                           size: file.size,
                           fileType: file.fileExtension,
                           sha256: "")
        }
        
        let prepareUploadRequest = PrepareUploadRequest(title: title, sessionID: sessionId, files: files)
        
        self.peerToPeerRepository.prepareUpload(prepareUpload: prepareUploadRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.handlePrepareUpload(completion:completion)
            }, receiveValue: { response in
                debugLog(response)
            }).store(in: &self.subscribers)
    }
    
    private func handlePrepareUpload(completion:Subscribers.Completion<APIError>) {
        switch completion {
        case .finished:
            self.viewAction = .displaySendingFiles
        case .failure(let error):
            debugLog(error)
            switch error {
            case .httpCode(HTTPErrorCodes.forbidden.rawValue):
                self.viewState = .prepareFiles
                self.viewAction = .showToast(message:LocalizablePeerToPeer.senderFilesRejected.localized)
            default:
                self.viewAction = .errorOccured
            }
        }
    }
    
    func closeConnection() {
        self.peerToPeerRepository.closeConnection(closeConnectionRequest:CloseConnectionRequest(sessionID: self.sessionId))
    }
}

struct SessionInfo {
    var sessionId : String?
    var transmissionId : String?
    
    init(sessionId: String? = nil, transmissionId: String? = nil) {
        self.sessionId = sessionId
        self.transmissionId = transmissionId
    }
}
