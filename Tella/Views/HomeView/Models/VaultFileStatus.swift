//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class VaultFileStatus {
    @Published var file : VaultFile
    @Published var isSelected : Bool
    
    init(file : VaultFile, isSelected : Bool) {
        self.file = file
        self.isSelected = isSelected
    }
}
