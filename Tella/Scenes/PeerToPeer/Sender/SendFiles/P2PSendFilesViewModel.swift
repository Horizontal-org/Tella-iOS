//
//  P2PSendFilesViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/4/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Combine
import Foundation

class P2PSendFilesViewModel: ObservableObject {
    
    var mainAppModel: MainAppModel
    var sessionId : String?
    var peerToPeerRepository: PeerToPeerRepository
    
    //MARK: -AddFilesViewModel
    @Published var addFilesViewModel: AddFilesViewModel
    @Published var title: String = ""
    @Published var validTitle: Bool = false
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel: MainAppModel, sessionId : String, peerToPeerRepository: PeerToPeerRepository) {
        self.mainAppModel = mainAppModel
        self.addFilesViewModel = AddFilesViewModel(mainAppModel: mainAppModel)
        self.sessionId = sessionId
        self.peerToPeerRepository = peerToPeerRepository
    }
    
    func prepareUpload() {
        
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
                
                debugLog(completion)
                
                switch completion {
                case .finished:
                    debugLog("finished")
                case .failure(let error):
                    debugLog(error)
                }
            }, receiveValue: { response in
                debugLog(response)
            }).store(in: &self.subscribers)
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
