//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class RecentFile : Hashable {
    static func == (lhs: RecentFile, rhs: RecentFile) -> Bool {
        lhs.file.id == rhs.file.id
    }

    func hash(into hasher: inout Hasher){
        hasher.combine(file.id.hashValue)
    }

    var file : VaultFileDB
    var rootFile : VaultFileDB
    var folderPathArray : [VaultFileDB]?

    init(file : VaultFileDB, rootFile : VaultFileDB, folderPathArray : [VaultFileDB]?) {
        self.file = file
        self.rootFile = rootFile
        self.folderPathArray = folderPathArray
    }
}
