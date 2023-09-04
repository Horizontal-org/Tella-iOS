//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class VaultDataSource : VaultDataSourceInterface {
    
    var database : VaultDataBase

    init(key: String?) {
        self.database = VaultDataBase(key: key)
    }

    func addVaultFile(file: VaultFileDB, parentId: String?) {
        self.database.addVaultFile(file: file, parentId: parentId)
    }
    
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB] {
        self.database.getVaultFiles(parentId: parentId, filter: filter, sort: sort)
    }
    
    func getVaultFile(id: String?) -> VaultFileDB? {
        return self.database.getVaultFile(id: id)
    }
    
    func getVaultFiles(ids: [String]) -> [VaultFileDB] {
        return self.database.getVaultFiles(ids: ids)
    }
    
    func renameVaultFile(id: String, name: String?) {
        self.database.renameVaultFile(id: id, name: name)
    }
    
    func moveVaultFile(id: String, newParentId: String) {
        self.database.moveVaultFile(id: id, newParentId: newParentId)
    }
    
    func deleteVaultFile(ids: [String]) {
        self.database.deleteVaultFile(ids: ids)
    }
}
