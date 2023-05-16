//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class RecentFile : Hashable {
    static func == (lhs: RecentFile, rhs: RecentFile) -> Bool {
        lhs.file.containerName == rhs.file.containerName
    }

    func hash(into hasher: inout Hasher){
        hasher.combine(file.containerName.hashValue)
    }

    var file : VaultFile
    var rootFile : VaultFile
    var folderPathArray : [VaultFile]?

    init(file : VaultFile, rootFile : VaultFile, folderPathArray : [VaultFile]?) {
        self.file = file
        self.rootFile = rootFile
        self.folderPathArray = folderPathArray
    }
}
