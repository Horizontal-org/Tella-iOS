//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

protocol VaultFilesManagerInterface {
    func addVaultFile(filePaths: [URL], parentId: String?) -> AnyPublisher<ImportVaultFileResult,Never>
    func addVaultFiles(files: [(VaultFileDB,String?)]) throws
    
    
    func addFolderFile(name:String, parentId: String?)
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB]
    func getVaultFile(id: String?) -> VaultFileDB?
    func getVaultFiles(ids: [String]) -> [VaultFileDB]
    func getRecentVaultFiles() -> [VaultFileDB]
    func renameVaultFile(id: String?, name: String?)
    func moveVaultFile(fileIds: [String], newParentId: String?)
    func deleteVaultFile(fileIds: [String])
    func deleteAllVaultFiles()
    func deleteVaultFile(vaultFiles: [VaultFileDB])
    func cancelImportAndEncryption()
}

