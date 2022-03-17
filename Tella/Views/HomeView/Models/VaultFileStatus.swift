//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class VaultFileStatus {
    var file : VaultFile
    var isSelected : Bool
    
    init(file : VaultFile, isSelected : Bool) {
        self.file = file
        self.isSelected = isSelected
    }
}
