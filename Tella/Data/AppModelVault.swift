//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

protocol AppModelVaultFilesInterface {
    func addVaultFile(filePaths: [URL], parentId: String?) -> AnyPublisher<ImportVaultFileResult,Never>
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB]
    func getVaultFile(id: String?) -> VaultFileDB?
    func getVaultFiles(ids: [String]) -> [VaultFileDB]
    func renameVaultFile(id: String, name: String?)
    func moveVaultFile(id: String, newParentId: String)
    func deleteVaultFile(ids: [String])
}


extension MainAppModel : AppModelVaultFilesInterface  {
    
    func addVaultFile(filePaths: [URL], parentId: String?) -> AnyPublisher<ImportVaultFileResult,Never> {
        vaultManager.addVaultFile(filePaths: filePaths, parentId: parentId)
    }
    
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB] {
        //TODO:
        return []
    }
    
    func getVaultFile(id: String?) -> VaultFileDB? {
        //TODO:
        return nil
    }
    
    func getVaultFiles(ids: [String]) -> [VaultFileDB] {
        return []
    }
    
    func renameVaultFile(id: String, name: String?) {
        //TODO:
    }
    
    func moveVaultFile(id: String, newParentId: String) {
        //TODO:
    }
    
    func deleteVaultFile(ids: [String]) {
        //TODO:
    }
    
    
    
}
