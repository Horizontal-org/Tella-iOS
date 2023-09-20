//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class VaultFileStatus {
    var file : VaultFileDB
    var isSelected : Bool
    
    init(file : VaultFileDB, isSelected : Bool) {
        self.file = file
        self.isSelected = isSelected
    }
}
