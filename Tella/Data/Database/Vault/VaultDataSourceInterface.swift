//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

protocol VaultDataSourceInterface {
    func addVaultFile(file : VaultFileDB, parentId: String?)
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB]
    func getVaultFile(id: String?) -> VaultFileDB?
    func getVaultFiles(ids: [String]) -> [VaultFileDB]
    func getRecentVaultFiles() -> [VaultFileDB]
    func renameVaultFile(id: String, name: String?)
    func moveVaultFile(fileIds: [String], newParentId: String?)
    func deleteVaultFile(ids: [String])
}
