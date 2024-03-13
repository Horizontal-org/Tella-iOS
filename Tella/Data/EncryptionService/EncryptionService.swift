//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class EncryptionService: ObservableObject {
    
    private var operationQueue: OperationQueue!
    private var subscribers : Set<AnyCancellable> = []
    var vaultFilesManager : VaultFilesManager?
    var mainAppModel: MainAppModel
    
    @Published var items : [BackgroundActivityModel] = []
    
    init(vaultFilesManager:VaultFilesManager?, mainAppModel: MainAppModel) {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        operationQueue = queue
        operationQueue.maxConcurrentOperationCount = 1
        self.vaultFilesManager = vaultFilesManager
        self.mainAppModel = mainAppModel
        
    }
    
    func addVaultFile(importedFiles: [ImportedFile],
                      parentId: String?,
                      shouldReloadVaultFiles:Binding<Bool>?,
                      deleteOriginal: Bool,
                      autoUpload: Bool) {
        
        Task {
            let fileDetails = await getFileDetails(importedFiles: importedFiles)
            
            addEncryptionOperations(fileDetails: fileDetails,
                                    parentId: parentId,
                                    shouldReloadVaultFiles: shouldReloadVaultFiles,
                                    deleteOriginal:deleteOriginal,
                                    autoUpload: autoUpload)
        }
    }
    
    
    private func getFileDetails(importedFiles: [ImportedFile]) async -> [VaultFileDetails] {
        
        var fileDetails : [VaultFileDetails] = []
        
        for importedFile in importedFiles {
            
            guard let fileDetail = await mainAppModel.vaultFilesManager?.getFileDetails(importedFile: importedFile) else { continue }
            fileDetails.append(fileDetail)
            
            let backgroundActivityModel = BackgroundActivityModel(vaultFile: fileDetail.file)
            DispatchQueue.main.async {
                self.items.append(backgroundActivityModel)
            }
        }
        
        return fileDetails
    }
    
    private func addEncryptionOperations(fileDetails:[VaultFileDetails],
                                         parentId: String?,
                                         shouldReloadVaultFiles:Binding<Bool>?,
                                         deleteOriginal: Bool,
                                         autoUpload: Bool) {
        
        for fileDetail in fileDetails {
            operationQueue.addOperation({
                
                let operation = EncryptionOperation(mainAppModel: self.mainAppModel)
                
                operation.addVaultFile(fileDetail: fileDetail,
                                       filePath: fileDetail.fileUrl,
                                       parentId: parentId,
                                       mainAppModel: self.mainAppModel,
                                       deleteOriginal: deleteOriginal)?
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { backgroundResult in
                        self.handleBackgroundResult(result: backgroundResult, fileDetail: fileDetail, autoUpload: autoUpload)
                        self.items.removeAll(where: {$0.id == fileDetail.file.id})
                        shouldReloadVaultFiles?.wrappedValue = true
                    }).store(in: &self.subscribers)
            })
        }
    }
    
    private func handleBackgroundResult(result : BackgroundActivityStatus,
                                        fileDetail: VaultFileDetails,
                                        autoUpload: Bool)  {
        switch result {
        case .completed(let vaultFile):
            if autoUpload {
                self.mainAppModel.sendAutoReportFile(file: vaultFile)
            }
        case .failed :
            self.displayEncryptionFailToast(title: fileDetail.file.name)
        default:
            break
        }
    }
    
    private func displayEncryptionFailToast(title: String?) {
        let message = String(format: LocalizableBackgroundActivities.encryptionFailToast.localized, title ?? "")
        Toast.displayToast(message: message)
    }
}
