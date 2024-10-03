//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class FilesActor {
    var files : [VaultFileDB] = []
    
    func add(vaultFile: VaultFileDB) {
        files.append(vaultFile)
    }
}
