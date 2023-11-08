//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class VaultDataSource : VaultDataSourceInterface {
    
    
    var database : VaultDatabase

    init(key: String?) throws {
        self.database = try VaultDatabase(key: key)
    }

    @discardableResult
    func addVaultFile(file : VaultFileDB, parentId: String?) -> Result<Int,Error> {
        self.database.addVaultFile(file: file, parentId: parentId)
    }
    
    func getVaultFiles(parentId: String?, filter: FilterType?, sort: FileSortOptions?) -> [VaultFileDB] {
        self.database.getVaultFiles(parentId: parentId, filter: filter, sort: sort)
    }
    
    func getVaultFile(id: String?) -> VaultFileDB? {
        return self.database.getVaultFile(id: id)
    }
    
    func getVaultFiles(ids: [String]) -> [VaultFileDB] {
        return self.database.getVaultFiles(ids: ids)
    }
    
    func getRecentVaultFiles() -> [VaultFileDB] {
        return self.database.getRecentVaultFiles()
    }

    func renameVaultFile(id: String?, name: String?) -> Result<Bool, Error> {
        self.database.renameVaultFile(id: id, name: name)
    }
    
    func moveVaultFile(fileIds: [String], newParentId: String?) -> Result<Bool, Error> {
        self.database.moveVaultFile(fileIds: fileIds, newParentId: newParentId)
    }
    
    func deleteVaultFile(ids: [String]) -> Result<Bool, Error> {
        self.database.deleteVaultFile(ids: ids)
    }
    
    func deleteAllVaultFiles() -> Result<Bool, Error> {
        self.database.deleteAllVaultFiles()
    }

}
