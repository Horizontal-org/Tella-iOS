//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

protocol VaultFilesManagerInterface {
    func addVaultFile(importedFiles: [ImportedFile], parentId: String?, deleteOriginal:Bool) -> AnyPublisher<ImportVaultFileResult,Never>
    func addVaultFile(filePaths: [URL], parentId: String?) -> AnyPublisher<ImportVaultFileResult,Never>
    func addVaultFiles(files: [VaultFileDetailsToMerge]) throws
    
    
    func addFolderFile(name: String, parentId: String?) -> Result<Int,Error>?
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB]
    func getVaultFile(id: String?) -> VaultFileDB?
    func getVaultFiles(ids: [String]) -> [VaultFileDB]
    func getRecentVaultFiles() -> [VaultFileDB]
    func renameVaultFile(id: String?, name: String?) -> Result<Bool, Error>?
    func moveVaultFile(fileIds: [String], newParentId: String?) -> Result<Bool, Error>?
   
    @discardableResult
    func deleteVaultFile(fileIds ids: [String]) -> Result<Bool, Error>?
    
    func deleteAllVaultFiles() -> Result<Bool, Error>?
    func deleteVaultFile(vaultFiles: [VaultFileDB]) -> Result<Bool, Error>?
    func cancelImportAndEncryption()
}

