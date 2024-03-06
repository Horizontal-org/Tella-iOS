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
    
    func addVaultFile(filePaths: [URL], parentId: String?, shouldReloadVaultFiles:Binding<Bool>?) {
        
        Task {
            let fileDetails = await getFileDetails(filePaths: filePaths)
            
            addEncryptionOperations(fileDetails: fileDetails, parentId: parentId, shouldReloadVaultFiles: shouldReloadVaultFiles)
        }
    }
    
    
    func getFileDetails(filePaths: [URL]) async -> [VaultFileDetails] {
        
        var fileDetails : [VaultFileDetails] = []
        
        for filePath in filePaths {
            
            guard let fileDetail = await mainAppModel.vaultFilesManager?.getFileDetails(filePath: filePath) else { continue }
            fileDetails.append(fileDetail)
            
            let backgroundActivityModel = BackgroundActivityModel(vaultFile: fileDetail.file)
            DispatchQueue.main.async {
                self.items.append(backgroundActivityModel)
            }
        }
        
        return fileDetails
    }
    
    func addEncryptionOperations( fileDetails:[VaultFileDetails], parentId: String?, shouldReloadVaultFiles:Binding<Bool>?) {
        
        for fileDetail in fileDetails {
            operationQueue.addOperation({
                
                let operation = EncryptionOperation(mainAppModel: self.mainAppModel)
                
                operation.addVaultFile(fileDetail: fileDetail, filePath: fileDetail.fileUrl, parentId: parentId, mainAppModel: self.mainAppModel)?
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { backgroundResult in
                        
                        if backgroundResult == .failed {
                            self.displayEncryptionFailToast(title: fileDetail.file.name)
                        }
                        self.items.removeAll(where: {$0.id == fileDetail.file.id})
                        shouldReloadVaultFiles?.wrappedValue = true
                        
                    }).store(in: &self.subscribers)
            })
        }
    }
    
    func displayEncryptionFailToast(title: String?) {
        let message = String(format: LocalizableBackgroundActivities.encryptionFailToast.localized, title ?? "")
        Toast.displayToast(message: message)
    }
}
