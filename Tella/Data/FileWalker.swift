//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class FileWalker {
    
    var resultFiles : [VaultFileDB] = []
    var vaultDatabase : VaultDataBaseProtocol?
    
    init( vaultDatabase: VaultDataBaseProtocol) {
        self.vaultDatabase = vaultDatabase
    }
    
    func walkWithDirectories(root:VaultFileDB) -> [VaultFileDB]{
        
        let vaultFiles = vaultDatabase?.getVaultFiles(parentId: root.id, filter: .all, sort: nil)
        
        vaultFiles?.forEach({ vaultFile in
            
            resultFiles.append(vaultFile)
            
            if vaultFile.type == .directory {
                _ = self.walkWithDirectories(root: vaultFile)
            }
        })
        return resultFiles
    }
    
    func walk(root:VaultFileDB) -> [VaultFileDB] {
        
        let vaultFiles = vaultDatabase?.getVaultFiles(parentId: root.id, filter: .all, sort: nil)
        
        vaultFiles?.forEach({ vaultFile in

            if vaultFile.type == .directory {
                _ = self.walk(root: vaultFile)
            } else {
                resultFiles.append(vaultFile)
            }
        })
        return resultFiles
    }
}
