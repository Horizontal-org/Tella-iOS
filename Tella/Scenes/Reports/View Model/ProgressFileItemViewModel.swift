//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class ProgressFileItemViewModel {
    var file : VaultFile
    @Published var progression : String
    
    init(file: VaultFile, progression: String) {
        self.file = file
        self.progression = progression
    }
}


