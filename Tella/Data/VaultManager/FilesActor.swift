//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class FilesActor {
    var files : [VaultFileDB] = []
    
    func add(vaultFile: VaultFileDB) {
        files.append(vaultFile)
    }
}
