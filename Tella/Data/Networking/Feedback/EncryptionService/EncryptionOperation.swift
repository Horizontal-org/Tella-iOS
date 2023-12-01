//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//


import Foundation
import Combine

class EncryptionOperation:Operation, WebRepository {
    
    public var mainAppModel :MainAppModel!
    
    private var cancellable: AnyCancellable?
    private var subscribers : Set<AnyCancellable> = []
    
    init(mainAppModel :MainAppModel) {
        super.init()
        self.mainAppModel = mainAppModel
    }
    
    override func main() {
        super.main()
        addVaultFile()
    }
    
    public func addVaultFile() {
        
        self.mainAppModel.vaultFilesManager?.addVaultFile(filePaths: filteredURLfiles, parentId: self.rootFile?.wrappedValue?.id)
            .sink { importVaultFileResult in
                
                switch importVaultFileResult {
                case .fileAdded(let vaultFiles):
                    self.handleSuccessAddingFiles(urlfiles: filteredURLfiles, originalURLs: originalURLs, vaultFiles: vaultFiles)
                case .importProgress(let importProgress):
                    self.updateProgress(importProgress:importProgress)
                }
                
            }.store(in: &cancellable)
    }
    
}


