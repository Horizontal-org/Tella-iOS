//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
