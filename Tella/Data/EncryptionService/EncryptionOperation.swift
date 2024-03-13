//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//


import Foundation
import Combine

class EncryptionOperation:Operation, WebRepository {
    
    public var mainAppModel :MainAppModel!
    
    private var cancellable: AnyCancellable?
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel :MainAppModel) {
        super.init()
        self.mainAppModel = mainAppModel
    }

    public func addVaultFile(fileDetail: VaultFileDetails, 
                             filePath: URL,
                             parentId: String?,
                             mainAppModel: MainAppModel,
                             deleteOriginal:Bool) -> AnyPublisher<BackgroundActivityStatus,Never>? {
        return self.mainAppModel.vaultFilesManager?.addVaultFile(fileDetail: fileDetail, 
                                                                 filePath: filePath,
                                                                 parentId: parentId,
                                                                 deleteOriginal: deleteOriginal)
    }
    
}


