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
    case displaySendingFiles(peerToPeerReport:PeerToPeerReport)
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
    
    var report : PeerToPeerReport?
    
    
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
        var peerToPeerFileArray: [PeerToPeerFile] = []
        guard let sessionId else { return }
        
        let files : [P2PFile] = addFilesViewModel.files.compactMap { file in
            
            guard let id = file.id else {
                return nil
            }
            peerToPeerFileArray.append(PeerToPeerFile(fileId: id, transmissionId: "", vaultFile: file))
            
            return P2PFile(id: id,
                           fileName: file.name.appending(".\(file.fileExtension)"),
                           size: file.size,
                           fileType: file.mimeType,
                           thumbnail: file.thumbnail,
                           sha256: "")
        }
        
        let prepareUploadRequest = PrepareUploadRequest(title: title, sessionID: sessionId, files: files)
        
        self.peerToPeerRepository.prepareUpload(prepareUpload: prepareUploadRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.handlePrepareUpload(completion:completion)
            }, receiveValue: { response in
                
                _ = peerToPeerFileArray.compactMap  { file in
                    
                    let transmissionId = response.files?.filter({$0.id == file.fileId }).first?.transmissionID
                    return  file.transmissionId = transmissionId
                }
                
                let report = PeerToPeerReport(title: self.title, sessionId: sessionId, vaultfiles: peerToPeerFileArray)
                self.report = report
                self.viewAction = .displaySendingFiles(peerToPeerReport: report)
                
            }).store(in: &self.subscribers)
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
