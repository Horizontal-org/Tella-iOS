//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class VaultFileInfo {
    
    var vaultFile : VaultFileDB
    var data : Data
    var url : URL
    
    init(vaultFile: VaultFileDB, data: Data, url: URL) {
        self.vaultFile = vaultFile
        self.data = data
        self.url = url
    }
}

