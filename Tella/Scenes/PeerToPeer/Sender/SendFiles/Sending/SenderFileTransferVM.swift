//
//  SenderFileTransferVM.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 15/5/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Combine

class SenderFileTransferVM: FileTransferVM {
    
    var repository: PeerToPeerRepository?
    var report: PeerToPeerReport?
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel: MainAppModel,
         repository: PeerToPeerRepository,
         report: PeerToPeerReport) {
        
        self.repository = repository
        self.report = report
        
        super.init(mainAppModel: mainAppModel,
                   title: LocalizablePeerToPeer.senderSendingAppBar.localized,
                   bottomSheetTitle: LocalizablePeerToPeer.stopSharingTitle.localized,
                   bottomSheetMessage: LocalizablePeerToPeer.stopSharingSheetExpl.localized)
        
        submitReport()
    }
    
    func initVaultFile() {}
    
    func submitReport() {
        
        Task {
            
            guard let vaultfiles = report?.vaultfiles else { return }
            
            for file in vaultfiles {
                file.url =  await self.mainAppModel.vaultManager.loadVaultFileToURLAsync(file: file.vaultFile, withSubFolder: true)
            }
            
            vaultfiles.forEach({ file in
                guard let url = file.url else { return }
                repository?.uploadFile(fileUploadRequest: FileUploadRequest(sessionID: report?.sessionId, transmissionID: file.transmissionId, fileID: file.fileId), fileURL: url)
                    .receive(on: DispatchQueue.main)
                
                    .sink { completion in
                        debugLog("Completion: \(completion)")
                    } receiveValue: { response in
                        debugLog("Response: \(response)")
                    }.store(in: &subscribers)
            })
        }
    }
    
    func initializeProgressionInfos() {
        
    }
    
    func updateCurrentFile(uploadProgressInfo : UploadProgressInfo) {
        
    }
    
    func checkAllFilesAreUploaded() {
        
    }
    
    func markReportAsSubmissionErrorIfNeeded(filesAreNotfinishUploading: [ReportVaultFile] = []) {
        
    }
    
    func updateProgressInfos(uploadProgressInfo : UploadProgressInfo) {
        
    }
    
    func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func deleteFilesAfterSubmission() {
    }
    
    override func stopTask() {
    }
}
