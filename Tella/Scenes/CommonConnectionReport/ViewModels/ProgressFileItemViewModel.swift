//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class ProgressFileItemViewModel: ObservableObject {
    
    let file: VaultFileDB
    
    @Published var transferSummary: String
    @Published var transferProgress: Double?

    init(file: VaultFileDB, transferSummary: String, transferProgress: Double? = nil) {
        self.file = file
        self.transferSummary = transferSummary
        self.transferProgress = transferProgress
    }
}
