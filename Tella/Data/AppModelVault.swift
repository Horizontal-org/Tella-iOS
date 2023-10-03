//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

protocol AppModelVaultFilesInterface {
    func addVaultFile(filePaths: [URL], parentId: String?) -> AnyPublisher<ImportVaultFileResult,Never>
    func addFolder(name:String, parentId: String?)
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB]
    func getVaultFile(id: String?) -> VaultFileDB?
    func getVaultFiles(ids: [String]) -> [VaultFileDB]
    func renameVaultFile(id: String, name: String?)
    func moveVaultFile(selectedFilesIds: [String], newParentId: String?)
    func deleteVaultFile(vaultFiles: [VaultFileDB])
    func delete(filesIds: [String])
    func deleteAllVaultFiles()
}


extension MainAppModel : AppModelVaultFilesInterface  {
    
    func addFolder(name:String, parentId: String?)  {
        vaultManager.addFolderFile(name: name, parentId: parentId)
    }

    func addVaultFile(filePaths: [URL], parentId: String?) -> AnyPublisher<ImportVaultFileResult,Never> {
        vaultManager.addVaultFile(filePaths: filePaths, parentId: parentId)
    }
    
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB] {
        return vaultManager.getVaultFiles(parentId: parentId, filter: filter, sort: sort) 
    }
    
    func getVaultFile(id: String?) -> VaultFileDB? {
        return vaultManager.getVaultFile(id: id)
    }
    
    func getVaultFiles(ids: [String]) -> [VaultFileDB] {
       return vaultManager.getVaultFiles(ids: ids)
    }
    
    func renameVaultFile(id: String, name: String?) {
        vaultManager.renameVaultFile(id: id, name: name)
    }
    
    func moveVaultFile(selectedFilesIds: [String], newParentId: String?) {
        vaultManager.moveVaultFile(fileIds: selectedFilesIds, newParentId: newParentId)
    }
    
    func deleteVaultFile(vaultFiles: [VaultFileDB]) {
        vaultManager.deleteVaultFile(vaultFiles: vaultFiles)
    }
    
    func delete(filesIds: [String]) {
        vaultManager.deleteVaultFile(fileIds: filesIds)
    }


    func deleteAllVaultFiles() {
        vaultManager.deleteAllVaultFiles()
    }

}
