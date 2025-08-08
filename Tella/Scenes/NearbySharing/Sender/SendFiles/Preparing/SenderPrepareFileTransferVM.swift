//
//  SenderPrepareFileTransferVM.swift
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
    var session : NearbySharingSession
    var nearbySharingRepository: NearbySharingRepository
    
    //MARK: -AddFilesViewModel
    @Published var addFilesViewModel: AddFilesViewModel
    @Published var title: String = ""
    @Published var validTitle: Bool = false
    
    @Published var viewAction: SenderPrepareFileTransferAction = .none
    @Published var viewState: SenderPrepareFileTransferState = .prepareFiles
    @Published var reportIsValid : Bool = false
    
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel: MainAppModel, session : NearbySharingSession, nearbySharingRepository: NearbySharingRepository) {
        self.mainAppModel = mainAppModel
        self.addFilesViewModel = AddFilesViewModel(mainAppModel: mainAppModel)
        self.session = session
        self.nearbySharingRepository = nearbySharingRepository
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
        session.title = title
        var nearbySharingFileArray: [String: NearbySharingTransferredFile] = [:]
        let sessionId = session.sessionId
        
        let files: [NearbySharingFile] = addFilesViewModel.files.compactMap { file in
            guard let id = file.id else {
                return nil
            }
            
            let nearbySharingFile = NearbySharingFile(
                id: id,
                fileName: file.name.appending(".\(file.fileExtension)"),
                size: file.size,
                fileType: file.mimeType,
                thumbnail: file.thumbnail,
                sha256: ""
            )
            
            nearbySharingFileArray[id] = NearbySharingTransferredFile(vaultFile: file)
            return nearbySharingFile
        }
        
        let prepareUploadRequest = PrepareUploadRequest(
            title: title,
            sessionID: sessionId,
            files: files
        )
        
        self.nearbySharingRepository.prepareUpload(prepareUpload: prepareUploadRequest)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.handlePrepareUpload(completion: completion)
                }, receiveValue: { response in
                    
                    nearbySharingFileArray.values.forEach { file in
                        if let transmissionId = response.files?.first(where: { $0.id == file.file.id })?.transmissionID {
                            file.transmissionId = transmissionId
                        }
                    }
                    self.session.files = nearbySharingFileArray
                    self.viewAction = .displaySendingFiles
                }
            )
            .store(in: &subscribers)
    }
    
    private func handlePrepareUpload(completion:Subscribers.Completion<APIError>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            debugLog(error)
            switch error {
            case .httpCode(HTTPErrorCodes.forbidden.rawValue):
                self.viewState = .prepareFiles
                self.viewAction = .showToast(message:LocalizableNearbySharing.senderFilesRejected.localized)
            default:
                self.viewAction = .errorOccured
            }
        }
    }
    
    func closeConnection() {
        let request = CloseConnectionRequest(sessionID: session.sessionId)
        nearbySharingRepository.closeConnection(closeConnectionRequest: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &subscribers)
    }
}
