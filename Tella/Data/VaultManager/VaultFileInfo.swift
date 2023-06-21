//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class VaultFileInfo {
    
    var vaultFile : VaultFile
    var data : Data
    var url : URL
    
    init(vaultFile: VaultFile, data: Data, url: URL) {
        self.vaultFile = vaultFile
        self.data = data
        self.url = url
    }
}

