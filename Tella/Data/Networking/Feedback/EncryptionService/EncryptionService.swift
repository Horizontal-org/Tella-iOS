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
    
    @Published var items : [BackgroundActivityModel] = []
    
    init(vaultFilesManager:VaultFilesManager?) {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        operationQueue = queue
        // operationQueue.maxConcurrentOperationCount = 1
        self.vaultFilesManager = vaultFilesManager
    }
    
    func addVaultFile(filePaths: [URL], parentId: String?, mainAppModel: MainAppModel, shouldReloadVaultFiles:Binding<Bool>?) {
        
        for filePath in filePaths {
            
            let operation = EncryptionOperation(mainAppModel: mainAppModel)
            
            operation.addVaultFile(filePath: filePath, parentId: parentId, mainAppModel: mainAppModel)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { backgroundResult in
                    self.handleImportVaultFileInBackgroundResult(backgroundResult: backgroundResult, shouldReloadVaultFiles: shouldReloadVaultFiles)
                }).store(in: &subscribers)
            
            operationQueue.addOperations([operation], waitUntilFinished: true)
        }
    }
    
    func handleImportVaultFileInBackgroundResult(backgroundResult:ImportVaultFileInBackgroundResult, shouldReloadVaultFiles:Binding<Bool>?)  {
        
        switch backgroundResult {
        case .fileAdded(let item):
            self.items.append(item)
        case .fileUpdated(let item):
            switch item.status {
            case .completed:
                self.items.removeAll(where: {$0.id == item.id})
                shouldReloadVaultFiles?.wrappedValue = true
            default:
                if let row = self.items.firstIndex(where: {$0.id == item.id}) {
                    self.items[row] = item
                }
            }
        }
    }
}
