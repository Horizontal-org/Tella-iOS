//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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


