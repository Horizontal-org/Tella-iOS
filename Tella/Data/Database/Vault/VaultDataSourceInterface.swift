//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

protocol VaultDataSourceInterface {
    
    @discardableResult
    func addVaultFile(file : VaultFileDB, parentId: String?) -> Result<Int,Error>
    
    func getVaultFiles(parentId: String?, filter: FilterType?, sort: FileSortOptions?) -> [VaultFileDB]
    func getVaultFile(id: String?) -> VaultFileDB?
    func getVaultFiles(ids: [String]) -> [VaultFileDB]
    func getRecentVaultFiles() -> [VaultFileDB]
    func renameVaultFile(id: String?, name: String?) -> Result<Bool, Error>
    func moveVaultFile(fileIds: [String], newParentId: String?) -> Result<Bool, Error>
    func deleteVaultFile(ids: [String]) -> Result<Bool, Error>
    func deleteAllVaultFiles() -> Result<Bool, Error>
}
