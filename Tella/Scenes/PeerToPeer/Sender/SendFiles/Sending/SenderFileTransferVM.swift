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

class SenderFileTransferVM: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published var progressFileItems : [ProgressFileItemViewModel] = []
    @Published var percentUploaded : Float = 0.0
    @Published var percentUploadedInfo : String = ""
    @Published var uploadedFiles : String = ""
    
    @Published var isLoading : Bool = false
    
    var isSubmissionInProgress: Bool {
        return false
    }
    
    @Published var shouldShowToast : Bool = false
    @Published var toastMessage : String = ""
    var repository : PeerToPeerRepository?
    
    var subscribers = Set<AnyCancellable>()
    var filesToUpload : [FileToUpload] = []
    
    init(mainAppModel: MainAppModel,
         repository : PeerToPeerRepository?) {
        
        self.mainAppModel = mainAppModel
        self.repository = repository
        
        initVaultFile()
        
        initializeProgressionInfos()
        
        initSubmission()
        
    }
    
    func initVaultFile() {}
    
    func initSubmission() {
        
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
    
    
    func stopServerListening() {
        // server.stopListening()
    }
}
