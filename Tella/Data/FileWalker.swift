//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
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
}
