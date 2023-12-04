//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class ProgressFileItemViewModel {
    var file : VaultFileDB
    @Published var progression : String
    
    init(file: VaultFileDB, progression: String) {
        self.file = file
        self.progression = progression
    }
}


